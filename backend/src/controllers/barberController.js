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
      services: services ? JSON.parse(services) : []
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
