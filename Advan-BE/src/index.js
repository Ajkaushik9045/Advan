import app from "./server.js";
import connectDB from "./config/database.js";
import config from "./config/index.js";
import { createServer } from "http";
import { initializeSocket } from "./services/socket.service.js";

// Connect to MongoDB
connectDB();

// Create HTTP server
const server = createServer(app);

// Initialize Socket.IO
initializeSocket(server);

// Start server
const PORT = config.port;
server.listen(PORT, () => {
  console.log(
    `🚀 Server running in ${process.env.NODE_ENV || "development"} mode on port ${PORT}`
  );
  console.log(`📡 Socket.IO server initialized`);
});
