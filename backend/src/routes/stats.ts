import { NextFunction, Response, Router } from 'express';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as statsService from '../services/stats.service';

const router = Router();

router.use(authMiddleware);

// GET /user/stats - Gamification stats
router.get('/stats', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const stats = await statsService.getUserStats(userId);
        res.json({ stats });
    } catch (e) {
        next(e);
    }
});

// GET /user/progress - Study progress
router.get('/progress', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const progress = await statsService.getUserProgress(userId);
        res.json({ progress });
    } catch (e) {
        next(e);
    }
});

// GET /user/daily - Daily statistics
router.get('/daily', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const dailyStats = await statsService.getDailyStats(userId);
        res.json({ dailyStats });
    } catch (e) {
        next(e);
    }
});

export default router;
