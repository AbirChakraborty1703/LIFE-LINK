// backend/config/mongodb.js
import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI;
    if (!uri) {
      throw new Error("MONGO_URI not defined in environment");
    }

    // Optimized connection options for Azure Cosmos DB
    const connectionOptions = {
      retryWrites: false, // Azure Cosmos DB doesn't support retryWrites
      maxPoolSize: 10, // Maintain up to 10 socket connections
      serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
      socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
      bufferMaxEntries: 0 // Disable mongoose buffering
    };

    await mongoose.connect(uri, connectionOptions);

    console.log("MongoDB connected successfully");
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.log('MongoDB disconnected');
    });

  } catch (err) {
    console.error("DB connection error:", err);
    process.exit(1);
  }
};

export default connectDB;
