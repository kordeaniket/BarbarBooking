import Barber from '../models/Barber.js';
import crypto from 'crypto';

// @desc    Create new barber
// @route   POST /api/barbers
// @access  Private (Admin only)
export const createBarber = async (req, res) => {
  try {
    const { name, shopName, email, mobile, city, address, shopNumber, businessLicense, services } = req.body;

    const barberExists = await Barber.findOne({ email });
    if (barberExists) {
      return res.status(400).json({ message: 'Barber with this email already exists' });
    }

    // Auto-generate password
    const generatedPassword = crypto.randomBytes(6).toString('hex');

    // MOCK EMAIL SENDING
    console.log('====================================');
    console.log(`MOCK EMAIL SENT TO: ${email}`);
    console.log(`SUBJECT: Your Barber Booking Account Created`);
    console.log(`BODY: Welcome ${name}! Your password is: ${generatedPassword}`);
    console.log('====================================');

    let profilePhotoPath = '';
    if (req.file) {
      profilePhotoPath = `/uploads/${req.file.filename}`;
    }

    const barber = await Barber.create({
      name,
      shopName,
      email,
      password: generatedPassword,
      mobile,
      location: { city, address },
      shopNumber,
      businessLicense,
      profilePhoto: profilePhotoPath,
      services: services ? JSON.parse(services) : [],
      isApproved: true
    });

    res.status(201).json({
      _id: barber._id,
      name: barber.name,
      email: barber.email,
      message: 'Barber created successfully. Password sent to email.'
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all barbers
// @route   GET /api/barbers
// @access  Private (Admin only)
export const getBarbers = async (req, res) => {
  try {
    const barbers = await Barber.find({}).select('-password');
    res.json(barbers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update barber
// @route   PUT /api/barbers/:id
// @access  Private (Admin only)
export const updateBarber = async (req, res) => {
  try {
    const { name, shopName, email, mobile, city, address, shopNumber, businessLicense, services } = req.body;
    const barber = await Barber.findById(req.params.id);

    if (barber) {
      barber.name = name || barber.name;
      barber.shopName = shopName || barber.shopName;
      barber.email = email || barber.email;
      barber.mobile = mobile || barber.mobile;
      barber.location = {
        city: city || barber.location.city,
        address: address || barber.location.address
      };
      barber.shopNumber = shopNumber || barber.shopNumber;
      barber.businessLicense = businessLicense || barber.businessLicense;
      if (services) barber.services = JSON.parse(services);

      if (req.file) {
        barber.profilePhoto = `/uploads/${req.file.filename}`;
      }

      const updatedBarber = await barber.save();
      res.json(updatedBarber);
    } else {
      res.status(404).json({ message: 'Barber not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete barber
// @route   DELETE /api/barbers/:id
// @access  Private (Admin only)
export const deleteBarber = async (req, res) => {
  try {
    const barber = await Barber.findByIdAndDelete(req.params.id);
    if (barber) {
      res.json({ message: 'Barber removed' });
    } else {
      res.status(404).json({ message: 'Barber not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Approve/Reject barber
// @route   PUT /api/barbers/:id/approve
// @access  Private (Admin only)
export const approveBarber = async (req, res) => {
  try {
    const { isApproved } = req.body;
    const barber = await Barber.findByIdAndUpdate(req.params.id, { isApproved }, { new: true });
    
    if (barber) {
      res.json(barber);
    } else {
      res.status(404).json({ message: 'Barber not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
