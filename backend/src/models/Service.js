import mongoose from 'mongoose';

const serviceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  defaultPrice: { type: Number, required: true },
  durationMinutes: { type: Number, required: true },
  barber: { type: mongoose.Schema.Types.ObjectId, ref: 'Barber' } // Optional for master services, required for barber-specific
}, { timestamps: true });

const Service = mongoose.model('Service', serviceSchema);
export default Service;
