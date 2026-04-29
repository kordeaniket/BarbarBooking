import express from 'express';
import { getTransactions, getBookings } from '../controllers/transactionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', protect, getTransactions);
router.get('/bookings', protect, getBookings);

export default router;
