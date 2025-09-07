import Request from "../models/Request.js";
import catchAsync from "../utils/catchAsync.utils.js";
import createError from "http-errors";
import { updateRequestStatus } from "../services/request.service.js";
import {
  emitItemConfirmation,
  emitRequestStatusChange,
} from "../services/socket.service.js";

/**
 * @desc Get all requests assigned to this receiver
 * @route GET /api/receiver/requests
 * @access Private (Receiver)
 */
export const getAssignedRequests = catchAsync(async (req, res, next) => {
  if (req.user.role !== "Receiver")
    return next(createError(403, "Only receivers can view assigned requests"));

  const requests = await Request.find({ assignedTo: req.user._id })
    .populate("requester", "userName email")
    .sort({ createdAt: -1 });

  res.status(200).json({
    status: "success",
    results: requests.length,
    data: requests,
  });
});

/**
 * @desc Review a single request
 * @route GET /api/receiver/requests/:id
 * @access Private (Receiver)
 */
export const reviewRequest = catchAsync(async (req, res, next) => {
  if (req.user.role !== "Receiver")
    return next(createError(403, "Only receivers can review requests"));

  const request = await Request.findOne({
    _id: req.params.id,
    assignedTo: req.user._id,
  }).populate("requester", "userName email");

  if (!request) return next(createError(404, "Request not found"));

  res.status(200).json({
    status: "success",
    data: request,
  });
});

/**
 * @desc Confirm availability of an item inside a request
 * @route PATCH /api/receiver/requests/:id/items/:itemId
 * @access Private (Receiver)
 */
export const confirmItem = catchAsync(async (req, res, next) => {
  if (req.user.role !== "Receiver")
    return next(createError(403, "Only receivers can confirm items"));

  const { available } = req.body;

  const request = await Request.findOne({
    _id: req.params.id,
    assignedTo: req.user._id,
  });
  if (!request) return next(createError(404, "Request not found"));

  const itemIdParam = req.params.itemId?.toString();
  let item = request.items.id(itemIdParam);
  if (!item) {
    // Fallback: allow matching by referenced Item id as well
    item = request.items.find((i) => {
      const ref = (i.item || "").toString();
      return ref === itemIdParam;
    });
  }
  if (!item) return next(createError(404, "Item not found in this request"));

  // Update item
  item.available = available;
  item.confirmedBy = req.user._id;

  await request.save();

  // Update overall request status
  await updateRequestStatus(request._id);

  // Get updated request to emit current status
  const updatedRequest = await Request.findById(request._id);

  // Emit real-time updates
  emitItemConfirmation(request._id, req.params.itemId, available, req.user._id);
  emitRequestStatusChange(
    request._id,
    updatedRequest.status,
    request.assignedTo
  );

  res.status(200).json({
    status: "success",
    message: `Item marked as ${available ? "Available" : "Not Available"}`,
    data: updatedRequest,
  });
});
