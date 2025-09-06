import { body, validationResult } from "express-validator";
import { ROLES } from "../utils/constants.utils.js";

export const signupValidator = [
    body("userName")
        .trim()
        .isLength({ min: 2, max: 50 })
        .withMessage("Name must be 2–50 characters long")
        .matches(/^[a-zA-Z\s]*$/)
        .withMessage("Name must contain only letters and spaces"),

    body("email").isEmail().withMessage("Invalid email format").normalizeEmail(),

    body("phoneNumber")
        .isLength({ min: 10, max: 10 })
        .withMessage("Phone number must be 10 digits")
        .isMobilePhone("any")
        .withMessage("Invalid phone number format"),

    body("password")
        .isLength({ min: 8 })
        .withMessage("Password must be at least 8 characters long")
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/)
        .withMessage(
            "Password must contain uppercase, lowercase, number, and special character"
        ),

    body("role")
        .optional()
        .isIn(Object.values(ROLES))
        .withMessage(`Role must be one of: ${Object.values(ROLES).join(", ")}`),

    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ status: "fail", errors: errors.array() });
        }
        next();
    },
];
export const loginValidator = [
    body("email").isEmail().withMessage("Invalid email format").normalizeEmail(),
    body("password").notEmpty().withMessage("Password is required"),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ status: "fail", errors: errors.array() });
        }
        next();
    },
];