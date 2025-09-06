import jwt from "jsonwebtoken";
import User from "../models/User.models.js";
import createError from "http-errors";
import config from "../config/index.js";

export const protect = async (req, res, next) => {
    let token;
    if (req.headers.authorization?.startsWith("Bearer")) {
        token = req.headers.authorization.split(" ")[1];
    }
    if (!token) return next(createError(401, "Not authorized"));

    try {
        // Use config.jwtSecret instead of process.env directly
        const decoded = jwt.verify(token, config.jwtSecret);
        const user = await User.findById(decoded.id);
        if (!user) return next(createError(401, "User not found"));
        req.user = user;
        next();
    } catch (err) {
        return next(createError(401, "Invalid token"));
    }
};


export const restrictTo = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) return next(createError(401, "Not authenticated"));
        if (!allowedRoles.includes(req.user.role)) {
            return next(createError(403, "You do not have permission to perform this action"));
        }
        next();
    };
};
