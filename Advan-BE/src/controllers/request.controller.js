import Request from "../models/Request.js";
import Item from "../models/Item.js";
import User from "../models/User.models.js";
import catchAsync from "../utils/catchAsync.utils.js";
import createError from "http-errors";
import { emitRequestUpdate } from "../services/socket.service.js";

/**
 * @desc Create a new request
 * @route POST /api/requests
 * @access Private (EndUser)
 */
export const createRequest = catchAsync(async (req, res, next) => {
  if (req.user.role !== "EndUser")
    return next(createError(403, "Only End Users can create requests"));

  const { items } = req.body;

  // Map items to include name and initial available=false
  const requestItems = await Promise.all(
    items.map(async (i) => {
      const dbItem = await Item.findById(i.itemId);
      return {
        item: dbItem._id,
        name: dbItem.name,
        quantity: i.quantity,
        available: false, // initially not confirmed
      };
    })
  );

  // Find an available receiver to assign this request
  const receiver = await User.findOne({
    role: "Receiver",
    isActive: true,
  }).sort({ assignedRequests: 1 }); // Assign to receiver with least requests

  if (!receiver) {
    return next(createError(503, "No receivers available to handle requests"));
  }

  const request = await Request.create({
    requester: req.user._id,
    items: requestItems,
    status: "Pending",
    assignedTo: receiver._id,
  });

  // Update receiver's assigned requests
  await User.findByIdAndUpdate(receiver._id, {
    $push: { assignedRequests: request._id },
  });

  // Emit real-time update
  emitRequestUpdate(request._id, {
    status: "Pending",
    assignedTo: receiver.userName,
    message: "New request created and assigned",
  });

  res.status(201).json({
    status: "success",
    data: request,
    message: `Request assigned to receiver: ${receiver.userName}`,
  });
});

/**
 * @desc Get all requests of logged-in user
 * @route GET /api/requests/my
 * @access Private (EndUser)
 */
export const getMyRequests = catchAsync(async (req, res, next) => {
  const requests = await Request.find({ requester: req.user._id })
    .populate("items.item", "name description") // populate item info
    .sort({ createdAt: -1 });

  res.status(200).json({
    status: "success",
    results: requests.length,
    data: requests,
  });
});

/**
 * @desc Get all requests (for admin/overview)
 * @route GET /api/requests
 * @access Private (Admin/All roles)
 */
export const getAllRequests = catchAsync(async (req, res, next) => {
  const requests = await Request.find()
    .populate("requester", "userName email")
    .populate("assignedTo", "userName email")
    .populate("items.item", "name description")
    .sort({ createdAt: -1 });

  res.status(200).json({
    status: "success",
    results: requests.length,
    data: requests,
  });
});
