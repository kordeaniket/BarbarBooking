import express from 'express';
import { registerCustomer, loginCustomer, loginBarber, registerBarber } from '../controllers/mobileAuthController.js';

const router = express.Router();

router.post('/customer/register', registerCustomer);
router.post('/customer/login', loginCustomer);
router.post('/barber/login', loginBarber);
router.post('/barber/register', registerBarber);

export default router;
