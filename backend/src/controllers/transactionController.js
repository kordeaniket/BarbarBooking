import Transaction from '../models/Transaction.js';
import Booking from '../models/Booking.js';

// @desc    Get all transactions
// @route   GET /api/transactions
// @access  Private (Admin only)
export const getTransactions = async (req, res) => {
  try {
    // Optionally add filtering here based on req.query
    const filter = {};
    if (req.query.barberId) filter.barber = req.query.barberId;
    if (req.query.paymentType) filter.paymentType = req.query.paymentType;

    const transactions = await Transaction.find(filter)
      .populate('barber', 'name shopName')
      .populate('customer', 'name email')
      .populate('booking', 'date service')
      .sort({ createdAt: -1 });

    res.json(transactions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all bookings
// @route   GET /api/bookings
// @access  Private (Admin only)
export const getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('barber', 'name shopName')
      .populate('customer', 'name email')
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
