import { body, validationResult } from "express-validator";

export const confirmItemValidator = [
    body("available")
        .isBoolean()
        .withMessage("Available field must be true or false"),

    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ status: "fail", errors: errors.array() });
        }
        next();
    },
];
