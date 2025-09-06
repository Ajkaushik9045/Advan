import app from "./server.js";
import connectDB from "./config/database.js";
import config from "./config/index.js";

// Connect to MongoDB
connectDB();

// Start server
const PORT = config.port;
app.listen(PORT, () => {
  console.log(`🚀 Server running in ${process.env.NODE_ENV || "development"} mode on port ${PORT}`);
});
