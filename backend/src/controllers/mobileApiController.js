import Barber from '../models/Barber.js';
import Booking from '../models/Booking.js';
import Transaction from '../models/Transaction.js';
import Service from '../models/Service.js';

// @desc    Get active barbers
// @route   GET /api/mobile/barbers
// @access  Private (Customer)
export const getActiveBarbers = async (req, res) => {
  try {
    const barbers = await Barber.find({}).select('-password').populate('services');
    res.json(barbers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get barber details
// @route   GET /api/mobile/barbers/:id
// @access  Private
export const getBarberDetails = async (req, res) => {
  try {
    const barber = await Barber.findById(req.params.id).select('-password').populate('services');
    if (barber) {
      res.json(barber);
    } else {
      res.status(404).json({ message: 'Barber not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create new booking
// @route   POST /api/mobile/bookings
// @access  Private (Customer)
export const createBooking = async (req, res) => {
  const { barberId, serviceId, date, startTime, paymentType, amount } = req.body;

  try {
    const booking = await Booking.create({
      customer: req.user._id, // Assume populated by middleware
      barber: barberId,
      service: serviceId,
      date,
      startTime,
      status: 'pending'
    });

    const transaction = await Transaction.create({
      booking: booking._id,
      barber: barberId,
      customer: req.user._id,
      amount,
      paymentType,
      status: paymentType === 'cash' ? 'pending' : 'pending' // Online payments updated by razorpay webhook
    });

    // MOCK PUSH NOTIFICATION TO BARBER
    console.log(`[PUSH NOTIFICATION] To Barber ${barberId}: New booking from customer for ${date} at ${startTime}`);

    res.status(201).json({ booking, transaction });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get bookings history (Customer or Barber)
// @route   GET /api/mobile/bookings/history
// @access  Private
export const getBookingHistory = async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'customer') {
      filter.customer = req.user._id;
    } else if (req.user.role === 'barber') {
      filter.barber = req.user._id;
    } else {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const bookings = await Booking.find(filter)
      .populate('barber', 'name shopName location')
      .populate('customer', 'name mobile')
      .populate('service', 'name defaultPrice')
      .sort({ date: -1, startTime: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update booking status
// @route   PUT /api/mobile/bookings/:id/status
// @access  Private
export const updateBookingStatus = async (req, res) => {
  const { status } = req.body; // 'confirmed', 'completed', 'cancelled'

  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    booking.status = status;
    await booking.save();

    // MOCK PUSH NOTIFICATION
    if (req.user.role === 'barber') {
      console.log(`[PUSH NOTIFICATION] To Customer ${booking.customer}: Your booking has been ${status} by the barber.`);
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create barber specific service
// @route   POST /api/mobile/barber/services
// @access  Private (Barber)
export const createBarberService = async (req, res) => {
  const { name, description, defaultPrice, durationMinutes } = req.body;
  try {
    const service = await Service.create({
      name,
      description,
      defaultPrice,
      durationMinutes,
      barber: req.user._id
    });

    console.log('Service created:', service._id);

    const updatedBarber = await Barber.findByIdAndUpdate(req.user._id, {
      $push: { services: service._id }
    }, { new: true });

    console.log('Barber updated. Services count:', updatedBarber.services.length);

    res.status(201).json(service);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update payment status
// @route   PUT /api/mobile/bookings/:id/payment
// @access  Private (Barber)
export const updatePaymentStatus = async (req, res) => {
  try {
    const { paymentStatus, paymentType } = req.body;
    
    // Find booking and populate service to get price
    const booking = await Booking.findById(req.params.id).populate('service');
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    booking.paymentStatus = paymentStatus;
    if (paymentStatus === 'received') {
      booking.status = 'completed'; // Auto-complete booking when paid
    }
    
    await booking.save();

    // Create a transaction record if payment was received
    if (paymentStatus === 'received') {
      await Transaction.create({
        booking: booking._id,
        barber: booking.barber,
        customer: booking.customer,
        amount: booking.service.defaultPrice,
        paymentType: paymentType || 'cash',
        status: 'completed'
      });
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update barber service
// @route   PUT /api/mobile/barber/services/:id
// @access  Private (Barber)
export const updateBarberService = async (req, res) => {
  const { name, description, defaultPrice, durationMinutes } = req.body;
  try {
    const service = await Service.findOneAndUpdate(
      { _id: req.params.id, barber: req.user._id },
      { name, description, defaultPrice, durationMinutes },
      { new: true }
    );

    if (!service) return res.status(404).json({ message: 'Service not found or unauthorized' });

    res.json(service);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete barber service
// @route   DELETE /api/mobile/barber/services/:id
// @access  Private (Barber)
export const deleteBarberService = async (req, res) => {
  try {
    const service = await Service.findOneAndDelete({ _id: req.params.id, barber: req.user._id });

    if (!service) return res.status(404).json({ message: 'Service not found or unauthorized' });

    // Remove from Barber's services array
    await Barber.findByIdAndUpdate(req.user._id, {
      $pull: { services: req.params.id }
    });

    res.json({ message: 'Service deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get available slots for a barber on a date
// @route   GET /api/mobile/barbers/:id/slots
// @access  Private
export const getAvailableSlots = async (req, res) => {
  const { date, serviceId } = req.query;
  try {
    const service = await Service.findById(serviceId);
    if (!service) return res.status(404).json({ message: 'Service not found' });

    const duration = service.durationMinutes;
    const bookings = await Booking.find({
      barber: req.params.id,
      date: new Date(date),
      status: { $in: ['pending', 'confirmed'] }
    });

    // Business hours: 09:00 to 20:00
    const startHour = 9;
    const endHour = 20;
    const slots = [];

    // Helper to convert HH:mm to minutes from midnight
    const toMinutes = (timeStr) => {
      const [h, m] = timeStr.split(':').map(Number);
      return h * 60 + m;
    };

    // Prepare booked time ranges
    const bookedRanges = bookings.map(b => {
      // For now, assume bookings have durations. If not, default to 30m.
      // We'd ideally populate the service for each booking here.
      return {
        start: toMinutes(b.startTime),
        end: toMinutes(b.startTime) + 30 // Default 30m if duration not in booking
      };
    });

    for (let hour = startHour; hour < endHour; hour++) {
      for (let min = 0; min < 60; min += 30) {
        const slotStart = hour * 60 + min;
        const slotEnd = slotStart + duration;

        // Don't go past business hours
        if (slotEnd > endHour * 60) break;

        const time = `${hour.toString().padStart(2, '0')}:${min.toString().padStart(2, '0')}`;

        // Check if this range [slotStart, slotEnd] overlaps with any booking
        const isConflict = bookedRanges.some(range => {
          return (slotStart < range.end && slotEnd > range.start);
        });

        if (!isConflict) {
          slots.push(time);
        }
      }
    }

    res.json(slots);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user transactions
// @route   GET /api/mobile/transactions
// @access  Private
export const getUserTransactions = async (req, res) => {
  try {
    const filter = req.user.role === 'barber' ? { barber: req.user._id } : { customer: req.user._id };
    
    const transactions = await Transaction.find(filter)
      .populate('barber', 'name shopName')
      .populate('customer', 'name mobile')
      .populate({
        path: 'booking',
        populate: { path: 'service' }
      })
      .sort({ createdAt: -1 });

    res.json(transactions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
