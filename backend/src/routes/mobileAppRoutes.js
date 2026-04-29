import express from 'express';
import { 
  getActiveBarbers, 
  getBarberDetails, 
  createBooking, 
  getBookingHistory, 
  updateBookingStatus 
} from '../controllers/mobileApiController.js';
import { protectMobile } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/barbers', protectMobile, getActiveBarbers);
router.get('/barbers/:id', protectMobile, getBarberDetails);

router.post('/bookings', protectMobile, createBooking);
router.get('/bookings/history', protectMobile, getBookingHistory);
router.put('/bookings/:id/status', protectMobile, updateBookingStatus);

export default router;
