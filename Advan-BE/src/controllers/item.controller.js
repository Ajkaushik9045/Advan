import Item from "../models/Item.js";
import catchAsync from "../utils/catchAsync.utils.js";
import createError from "http-errors";

/**
 * @desc Add new item (Receiver only)
 * @route POST /api/items
 * @access Private (Receiver)
 */
export const addItem = catchAsync(async (req, res, next) => {
    // Only Receiver can add items
    if (req.user.role !== "Receiver") {
        return next(createError(403, "Only receivers can add items"));
    }

    const { name, description, quantity } = req.body;

    // Validate quantity
    if (!quantity || quantity < 1) {
        return next(createError(400, "Quantity must be at least 1"));
    }

    // Check if item already exists
    const existing = await Item.findOne({ name });
    if (existing) {
        return next(createError(400, "Item with this name already exists"));
    }

    // Create new item
    const item = await Item.create({
        name,
        description,
        quantity,
        addedBy: req.user._id,
    });

    res.status(201).json({
        status: "success",
        data: {
            id: item._id,
            name: item.name,
            quantity: item.quantity,
            description: item.description,
            addedBy: item.addedBy,
            createdAt: item.createdAt,
        },
    });
});

/**
 * @desc Get all active items
 * @route GET /api/items
 * @access Public
 */
export const getItems = catchAsync(async (req, res) => {
    const items = await Item.find({ isActive: true }).sort({ createdAt: -1 });

    res.status(200).json({
        status: "success",
        results: items.length,
        data: items.map((item) => ({
            id: item._id,
            name: item.name,
            quantity: item.quantity,
            description: item.description,
            addedBy: item.addedBy,
            createdAt: item.createdAt,
        })),
    });
});
