import jwt from 'jsonwebtoken';
import Admin from '../models/Admin.js';
import Customer from '../models/Customer.js';
import Barber from '../models/Barber.js';

// Middleware for Admin Portal
export const protect = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Check if it's an admin token
      req.user = await Admin.findById(decoded.id).select('-password');
      if (!req.user) {
         return res.status(401).json({ message: 'Not authorized as admin' });
      }
      req.user.role = 'admin';
      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

// Middleware for Mobile App (Customer & Barber)
export const protectMobile = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      if (decoded.role === 'customer') {
        req.user = await Customer.findById(decoded.id).select('-password');
        if (!req.user) return res.status(401).json({ message: 'Customer not found' });
        req.user.role = 'customer';
      } else if (decoded.role === 'barber') {
        req.user = await Barber.findById(decoded.id).select('-password');
        if (!req.user) return res.status(401).json({ message: 'Barber not found' });
        req.user.role = 'barber';
      } else {
        return res.status(401).json({ message: 'Invalid role in token' });
      }

      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};
