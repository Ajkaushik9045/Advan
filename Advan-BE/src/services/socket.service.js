import { Server } from "socket.io";

let io;

export const initializeSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: process.env.CLIENT_URL || "http://localhost:3000",
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    console.log(`User connected: ${socket.id}`);

    // Join user to their role-specific room
    socket.on("join-room", (data) => {
      const { userId, role } = data;
      socket.join(`${role}-${userId}`);
      console.log(`User ${userId} joined ${role} room`);
    });

    // Join receiver to their assigned requests room
    socket.on("join-receiver-room", (receiverId) => {
      socket.join(`receiver-${receiverId}`);
      console.log(`Receiver ${receiverId} joined their room`);
    });

    socket.on("disconnect", () => {
      console.log(`User disconnected: ${socket.id}`);
    });
  });

  return io;
};

export const emitRequestUpdate = (requestId, update) => {
  if (io) {
    io.emit("request-update", {
      requestId,
      update,
      timestamp: new Date(),
    });
  }
};

export const emitRequestStatusChange = (requestId, newStatus, receiverId) => {
  if (io) {
    // Notify the assigned receiver
    io.to(`receiver-${receiverId}`).emit("request-status-change", {
      requestId,
      newStatus,
      timestamp: new Date(),
    });

    // Notify all connected users about the update
    io.emit("request-update", {
      requestId,
      status: newStatus,
      timestamp: new Date(),
    });
  }
};

export const emitItemConfirmation = (
  requestId,
  itemId,
  available,
  receiverId
) => {
  if (io) {
    io.to(`receiver-${receiverId}`).emit("item-confirmed", {
      requestId,
      itemId,
      available,
      timestamp: new Date(),
    });
  }
};

export { io };
