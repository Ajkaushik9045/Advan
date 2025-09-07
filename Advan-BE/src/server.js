import express from "express";
import morgan from "morgan";
import cors from "cors";
import cookieParser from "cookie-parser";
import { errorHandler } from "./middleware/errorHandler.middleware.js";
import authRoutes from "./routes/auth.routes.js";
import itemsRouter from "./routes/items.routes.js";
import requestRouter from "./routes/requests.routes.js";
import receiverRouter from "./routes/receiver.routes.js";

const app = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(cookieParser());
if (process.env.NODE_ENV === "development") app.use(morgan("dev"));

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/items", itemsRouter);
app.use("/api/requests", requestRouter);
app.use("/api/receiver", receiverRouter);

// Error handler
app.use(errorHandler);

export default app;
