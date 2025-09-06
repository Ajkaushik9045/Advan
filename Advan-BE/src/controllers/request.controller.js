import Request from "../models/Request.js";
import Item from "../models/Item.js";
import catchAsync from "../utils/catchAsync.utils.js";
import createError from "http-errors";
import { updateRequestStatus } from "../services/request.service.js";

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

    const request = await Request.create({
        requester: req.user._id,
        items: requestItems,
        status: "Pending",
    });

    res.status(201).json({
        status: "success",
        data: request,
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
