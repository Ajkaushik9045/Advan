import express from "express";
import { login, signup } from "../controllers/auth.controller.js";
import { loginValidator, signupValidator } from "../validators/auth.validator.js";

const router = express.Router();

router.post("/signup", signupValidator, signup);
router.post("/login", loginValidator, login);

export default router;
