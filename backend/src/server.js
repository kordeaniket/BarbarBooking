import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import connectDB from './config/db.js';

// Load environment variables
dotenv.config();

// Connect to MongoDB
connectDB().then(async () => {
  // Seed Super Admin if not exists
  try {
    const Admin = (await import('./models/Admin.js')).default;
    const adminExists = await Admin.findOne({ email: 'aniketkorde13@gmail.com' });
    if (!adminExists) {
      await Admin.create({
        email: 'aniketkorde13@gmail.com',
        password: 'password' // Will be hashed by pre-save hook
      });
      console.log('Super Admin seeded successfully');
    }
  } catch (error) {
    console.error('Admin seeding failed:', error.message);
  }
});

import authRoutes from './routes/authRoutes.js';
import barberRoutes from './routes/barberRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import transactionRoutes from './routes/transactionRoutes.js';

// Mobile routes
import mobileAuthRoutes from './routes/mobileAuthRoutes.js';
import mobileAppRoutes from './routes/mobileAppRoutes.js';
import mobilePaymentRoutes from './routes/mobilePaymentRoutes.js';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static uploads
app.use('/uploads', express.static('uploads'));

// Admin Routes
app.use('/api/auth', authRoutes);
app.use('/api/barbers', barberRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/transactions', transactionRoutes);

// Mobile App Routes
app.use('/api/mobile/auth', mobileAuthRoutes);
app.use('/api/mobile', mobileAppRoutes);
app.use('/api/mobile/payments', mobilePaymentRoutes);

// Basic route
app.get('/api', (req, res) => {
  res.json({ message: 'Welcome to Barber Booking API' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode).json({
    message: err.message,
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
