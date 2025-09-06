import express from "express";
import { addItem,  getItems } from "../controllers/item.controller.js";
import { protect, restrictTo } from "../middleware/auth.middleware.js";


const itemsRouter = express.Router();

itemsRouter
  .route("/")
  .post(protect, restrictTo("Receiver"), addItem) // only Receiver can add
  .get(getItems); // any logged-in user can view

export default itemsRouter;
