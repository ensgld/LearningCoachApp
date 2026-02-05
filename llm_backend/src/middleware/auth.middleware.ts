// Authentication middleware - JWT verification
import { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from '../common/errors';
import { jwtConfig } from '../config/jwt';

export interface AuthRequest extends Request {
    user?: {
        userId: string;
        email: string;
    };
}

export async function authMiddleware(req: AuthRequest, res: Response, next: NextFunction) {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new AppError(401, 'No token provided');
        }

        const token = authHeader.substring(7); // Remove 'Bearer ' prefix

        try {
            const decoded = jwt.verify(token, jwtConfig.accessTokenSecret) as { userId: string; email: string };
            req.user = decoded;
            next();
        } catch (error) {
            if (error instanceof jwt.TokenExpiredError) {
                throw new AppError(401, 'Token expired');
            }
            if (error instanceof jwt.JsonWebTokenError) {
                throw new AppError(401, 'Invalid token');
            }
            throw error;
        }
    } catch (error) {
        next(error);
    }
}
