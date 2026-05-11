import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';
import Barber from '../models/Barber.js';

const generateToken = (id, role) => {
  return jwt.sign({ id, role }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

// @desc    Register a new customer
// @route   POST /api/mobile/auth/customer/register
// @access  Public
export const registerCustomer = async (req, res) => {
  const { name, email, password, mobile, fcmToken } = req.body;

  try {
    const customerExists = await Customer.findOne({ email });
    if (customerExists) {
      return res.status(400).json({ message: 'Customer already exists' });
    }

    const customer = await Customer.create({
      name,
      email,
      password,
      mobile,
      fcmToken
    });

    if (customer) {
      res.status(201).json({
        _id: customer._id,
        name: customer.name,
        email: customer.email,
        role: 'customer',
        token: generateToken(customer._id, 'customer'),
      });
    } else {
      res.status(400).json({ message: 'Invalid customer data' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Login customer
// @route   POST /api/mobile/auth/customer/login
// @access  Public
export const loginCustomer = async (req, res) => {
  const { email, password, fcmToken } = req.body;

  try {
    const customer = await Customer.findOne({ email });

    if (customer && (await customer.matchPassword(password))) {
      if (fcmToken) {
        customer.fcmToken = fcmToken;
        await customer.save();
      }

      res.json({
        _id: customer._id,
        name: customer.name,
        email: customer.email,
        role: 'customer',
        token: generateToken(customer._id, 'customer'),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Login barber
// @route   POST /api/mobile/auth/barber/login
// @access  Public
export const loginBarber = async (req, res) => {
  const { email, password, fcmToken } = req.body;

  try {
    const barber = await Barber.findOne({ email });

    // Since we auto-generated passwords and hashed them via pre-save, we compare here
    if (barber && (await barber.matchPassword(password))) {
      if (fcmToken) {
        barber.fcmToken = fcmToken;
        await barber.save();
      }

      res.json({
        _id: barber._id,
        name: barber.name,
        shopName: barber.shopName,
        email: barber.email,
        role: 'barber',
        token: generateToken(barber._id, 'barber'),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Register a new barber
// @route   POST /api/mobile/auth/barber/register
// @access  Public
export const registerBarber = async (req, res) => {
  const { name, shopName, email, password, mobile, location, shopNumber, businessLicense, fcmToken } = req.body;

  try {
    const barberExists = await Barber.findOne({ email });
    if (barberExists) {
      return res.status(400).json({ message: 'Barber already exists' });
    }

    const barber = await Barber.create({
      name,
      shopName,
      email,
      password,
      mobile,
      location,
      shopNumber,
      businessLicense,
      fcmToken
    });

    if (barber) {
      res.status(201).json({
        _id: barber._id,
        name: barber.name,
        shopName: barber.shopName,
        email: barber.email,
        role: 'barber',
        token: generateToken(barber._id, 'barber'),
      });
    } else {
      res.status(400).json({ message: 'Invalid barber data' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

