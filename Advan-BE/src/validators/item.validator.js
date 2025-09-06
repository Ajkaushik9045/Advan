// validators/item.validator.js
import { body, validationResult } from "express-validator";

export const createItemValidator = [
    body("name")
        .trim()
        .notEmpty()
        .withMessage("Item name is required")
        .isLength({ max: 100 })
        .withMessage("Name cannot exceed 100 characters"),

    body("quantity").isInt({ min: 1 }).withMessage("Quantity must be at least 1"),

    body("description")
        .optional()
        .isLength({ max: 500 })
        .withMessage("Description cannot exceed 500 characters"),

    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ status: "fail", errors: errors.array() });
        }
        next();
    },
];
