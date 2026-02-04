import { NextFunction, Response, Router } from 'express';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as sessionService from '../services/study-session.service';

const router = Router();

// Protected routes
router.use(authMiddleware);

// Create a new study session
router.post('/', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const session = await sessionService.createSession(userId, req.body);
        res.status(201).json({ session });
    } catch (error) {
        next(error);
    }
});

// Get all study sessions
router.get('/', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const sessions = await sessionService.getSessions(userId);
        res.json({ sessions });
    } catch (error) {
        next(error);
    }
});

export default router;
