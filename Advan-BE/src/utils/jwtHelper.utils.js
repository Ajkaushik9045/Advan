import jwt from "jsonwebtoken";
import config from "../config/index.js";

export const signToken = (payload) => {
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpires,
  });
};

export const verifyToken = (token) => {
  return jwt.verify(token, config.jwtSecret);
};
