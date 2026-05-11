import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const barberSchema = new mongoose.Schema({
  name: { type: String, required: true },
  shopName: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  mobile: { type: String, required: true },
  location: {
    city: { type: String, required: true },
    address: { type: String, required: true }
  },
  shopNumber: { type: String, required: true },
  businessLicense: { type: String, required: true },
  profilePhoto: { type: String }, // path to the uploaded image
  services: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Service' }],
  fcmToken: { type: String } // Firebase Cloud Messaging Token
}, { timestamps: true });

// Hash password before saving
barberSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Method to compare password
barberSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

const Barber = mongoose.model('Barber', barberSchema);
export default Barber;
