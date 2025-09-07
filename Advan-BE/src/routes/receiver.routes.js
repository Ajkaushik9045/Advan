import express from "express";
import { protect, restrictTo } from "../middleware/auth.middleware.js";
import {
  getAssignedRequests,
  reviewRequest,
  confirmItem,
} from "../controllers/receiver.controller.js";
import { confirmItemValidator } from "../validators/receiver.validator.js";

const router = express.Router();

// Only Receiver role allowed
router.get("/requests", protect, restrictTo("Receiver"), getAssignedRequests);
router.get("/requests/:id", protect, restrictTo("Receiver"), reviewRequest);
router.patch(
  "/requests/:id/items/:itemId",
  protect,
  restrictTo("Receiver"),
  confirmItemValidator,
  confirmItem
);

export default router;
