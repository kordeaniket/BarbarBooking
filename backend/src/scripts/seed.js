import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Admin from '../models/Admin.js';
import connectDB from '../config/db.js';

dotenv.config();
connectDB();

const importData = async () => {
  try {
    await Admin.deleteMany(); // Clear existing

    const admin = new Admin({
      email: 'aniketkorde13@gmail.com',
      password: 'password', // will be hashed by pre-save hook
    });

    await admin.save();
    console.log('Admin Data Imported!');
    process.exit();
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
};

importData();
