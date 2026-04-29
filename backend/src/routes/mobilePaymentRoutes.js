import express from 'express';
import Razorpay from 'razorpay';
import crypto from 'crypto';
import Transaction from '../models/Transaction.js';
import { protectMobile } from '../middleware/authMiddleware.js';

const router = express.Router();

// @desc    Create Razorpay order
// @route   POST /api/mobile/payments/razorpay/order
// @access  Private (Customer)
router.post('/razorpay/order', protectMobile, async (req, res) => {
  try {
    const { amount } = req.body;
    
    // Fallback to dummy key if env not set for development
    const instance = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || 'rzp_test_dummykey123',
      key_secret: process.env.RAZORPAY_SECRET || 'dummysecret1234567890',
    });

    const options = {
      amount: amount * 100, // amount in smallest currency unit (paise)
      currency: "INR",
      receipt: `receipt_${Date.now()}`
    };

    const order = await instance.orders.create(options);
    if (!order) return res.status(500).send("Some error occured");

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @desc    Verify Razorpay payment
// @route   POST /api/mobile/payments/razorpay/verify
// @access  Private
router.post('/razorpay/verify', protectMobile, async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      transactionId
    } = req.body;

    // Verify signature
    const secret = process.env.RAZORPAY_SECRET || 'dummysecret1234567890';
    const sign = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSign = crypto
      .createHmac("sha256", secret)
      .update(sign.toString())
      .digest("hex");

    if (razorpay_signature === expectedSign) {
      // Payment is successful, update transaction status
      if (transactionId) {
        await Transaction.findByIdAndUpdate(transactionId, { status: 'completed' });
      }
      return res.status(200).json({ message: "Payment verified successfully" });
    } else {
      return res.status(400).json({ message: "Invalid signature sent!" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
