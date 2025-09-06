import mongoose from 'mongoose';
import config from './index.js';

const connectDB = async () => {
  try {
    await mongoose.connect(config.mongoUri);
    console.log(`MongoDB Connected: ${config.mongoUri}`);
  } catch (err) {
    console.error(`MongoDB connection error: ${err.message}`);
    process.exit(1);
  }
};

export default connectDB;
