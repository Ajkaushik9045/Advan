import User from "../models/User.models.js";
import createError from "http-errors";
import { signToken } from "../utils/jwtHelper.utils.js";
import catchAsync from "../utils/catchAsync.utils.js";
import { ROLES, MESSAGES } from "../utils/constants.utils.js";
import bcrypt from "bcryptjs";

/**
 * @desc Signup (EndUser or Receiver)
 * @route POST /api/auth/signup
 */
export const signup = catchAsync(async (req, res, next) => {
  const { userName, email, phoneNumber, password, role } = req.body;

  // Check duplicate
  const existing = await User.findOne({ email });
  if (existing) return next(createError(400, MESSAGES.EMAIL_REGISTERED));

  // Create user
  const user = await User.create({
    userName,
    email,
    phoneNumber,
    password,
    role: role || ROLES.END_USER,
  });

  // Sign JWT
  const token = signToken({ id: user._id, role: user.role });

  res.status(201).json({
    status: "success",
    token,
    data: {
      id: user._id,
      userName: user.userName,
      email: user.email,
      role: user.role,
    },
  });
});

/**
 * @desc Login user (EndUser or Receiver)
 * @route POST /api/auth/login
 */
export const login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  // Fetch user with password
  const user = await User.findOne({ email }).select("+password");
  if (!user) return next(createError(401, MESSAGES.INVALID_CREDENTIALS));

  // Compare passwords
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return next(createError(401, MESSAGES.INVALID_CREDENTIALS));

  // Sign JWT
  const token = signToken({ id: user._id, role: user.role });

  res.status(200).json({
    status: "success",
    token,
    data: {
      id: user._id,
      userName: user.userName,
      email: user.email,
      role: user.role,
    },
  });
});

/**
 * @desc Get current authenticated user
 * @route GET /api/auth/me
 */
export const me = catchAsync(async (req, res, next) => {
  if (!req.user) return next(createError(401, MESSAGES.UNAUTHORIZED));

  const user = await User.findById(req.user._id);
  if (!user) return next(createError(401, MESSAGES.UNAUTHORIZED));

  res.status(200).json({
    status: "success",
    data: {
      id: user._id,
      userName: user.userName,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
    },
  });
});
