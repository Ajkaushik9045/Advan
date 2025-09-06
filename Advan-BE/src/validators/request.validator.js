import { body, validationResult } from "express-validator";
import Item from "../models/Item.js";

export const requestValidator = [
    body("items")
        .isArray({ min: 1 })
        .withMessage("Items array is required and cannot be empty"),
    body("items.*.itemId")
        .notEmpty()
        .withMessage("Item ID is required")
        .custom(async (value) => {
            const item = await Item.findById(value);
            if (!item) throw new Error("Item does not exist");
            return true;
        }),
    body("items.*.quantity")
        .isInt({ min: 1 })
        .withMessage("Quantity must be at least 1"),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty())
            return res.status(400).json({ status: "fail", errors: errors.array() });
        next();
    },
];
