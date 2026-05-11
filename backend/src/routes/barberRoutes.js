import express from 'express';
import { createBarber, getBarbers, updateBarber, deleteBarber, approveBarber } from '../controllers/barberController.js';
import { protect } from '../middleware/authMiddleware.js';
import multer from 'multer';
import path from 'path';

const router = express.Router();

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, 'uploads/');
  },
  filename(req, file, cb) {
    cb(null, `barber-${Date.now()}${path.extname(file.originalname)}`);
  }
});
const upload = multer({ storage });

router.route('/')
  .post(protect, upload.single('profilePhoto'), createBarber)
  .get(protect, getBarbers);

router.route('/:id')
  .put(protect, upload.single('profilePhoto'), updateBarber)
  .delete(protect, deleteBarber);

router.route('/:id/approve')
  .put(protect, approveBarber);

export default router;
