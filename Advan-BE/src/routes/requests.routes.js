import express from "express";
import { protect } from "../middleware/auth.middleware.js";
import {
  createRequest,
  getMyRequests,
} from "../controllers/request.controller.js";
import { requestValidator } from "../validators/request.validator.js";

const requestRouter = express.Router();

// Only End Users can create requests
requestRouter.post("/", protect, requestValidator, createRequest);

// Get all requests submitted by the logged-in user
requestRouter.get("/my", protect, getMyRequests);

export default requestRouter;
