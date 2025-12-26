// Auth routes
import { NextFunction, Request, Response, Router } from 'express';
import { BadRequestError } from '../common/errors';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import {
    getUserProfile,
    LoginDTO,
    loginUser,
    logoutUser,
    refreshAccessToken,
    RegisterDTO,
    registerUser,
} from '../services/auth.service';

const router = Router();

// Validation helper
function validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// POST /auth/register
router.post('/auth/register', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { email, password, displayName } = req.body;
        console.log('📝 Register request received:', { email, displayName });

        // Validation
        if (!email || !password || !displayName) {
            throw new BadRequestError('Email, password, and displayName are required');
        }

        if (!validateEmail(email)) {
            throw new BadRequestError('Invalid email format');
        }

        if (password.length < 8) {
            throw new BadRequestError('Password must be at least 8 characters');
        }

        if (displayName.trim().length < 2) {
            throw new BadRequestError('Display name must be at least 2 characters');
        }

        const dto: RegisterDTO = {
            email: email.toLowerCase().trim(),
            password,
            displayName: displayName.trim(),
        };

        const result = await registerUser(dto);
        console.log('✅ User registered successfully:', { userId: result.user.id, email: result.user.email });
        res.status(201).json(result);
    } catch (error) {
        next(error);
    }
});

// POST /auth/login
router.post('/auth/login', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { email, password } = req.body;

        // Validation
        if (!email || !password) {
            throw new BadRequestError('Email and password are required');
        }

        const dto: LoginDTO = {
            email: email.toLowerCase().trim(),
            password,
        };

        const result = await loginUser(dto);
        res.status(200).json(result);
    } catch (error) {
        next(error);
    }
});

// POST /auth/refresh
router.post('/auth/refresh', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            throw new BadRequestError('Refresh token is required');
        }

        const result = await refreshAccessToken(refreshToken);
        res.status(200).json(result);
    } catch (error) {
        next(error);
    }
});

// GET /auth/me (protected)
router.get('/auth/me', authMiddleware, async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        if (!req.user) {
            throw new BadRequestError('User not authenticated');
        }

        const user = await getUserProfile(req.user.userId);
        res.status(200).json({ user });
    } catch (error) {
        next(error);
    }
});

// POST /auth/logout (protected)
router.post('/auth/logout', authMiddleware, async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        if (!req.user) {
            throw new BadRequestError('User not authenticated');
        }

        await logoutUser(req.user.userId);
        res.status(200).json({ message: 'Logged out successfully' });
    } catch (error) {
        next(error);
    }
});

export default router;
