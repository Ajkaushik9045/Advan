import express from "express";
import { protect, restrictTo } from "../middleware/auth.middleware.js";
import {
  createRequest,
  getMyRequests,
  getAllRequests,
} from "../controllers/request.controller.js";
import { requestValidator } from "../validators/request.validator.js";

const requestRouter = express.Router();

// Only End Users can create requests
requestRouter.post(
  "/",
  protect,
  restrictTo("EndUser"),
  requestValidator,
  createRequest
);

// Get all requests submitted by the logged-in user
requestRouter.get("/my", protect, restrictTo("EndUser"), getMyRequests);

// Get all requests (for admin/overview)
requestRouter.get("/", protect, getAllRequests);

export default requestRouter;
