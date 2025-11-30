import express from 'express';
import { loginUser, registerUser, syncGoogleUser } from '../controllers/authController.js';

const authRouter = express.Router();

// Định nghĩa các đuôi URL
authRouter.post('/signup', registerUser);
authRouter.post('/signin', loginUser);
authRouter.post('/google-sync', syncGoogleUser);

export default authRouter;