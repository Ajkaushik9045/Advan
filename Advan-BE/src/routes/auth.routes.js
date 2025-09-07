import express from "express";
import { login, signup, me } from "../controllers/auth.controller.js";
import {
  loginValidator,
  signupValidator,
} from "../validators/auth.validator.js";
import { protect } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/signup", signupValidator, signup);
router.post("/login", loginValidator, login);
router.get("/me", protect, me);

export default router;
