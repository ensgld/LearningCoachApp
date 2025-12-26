// Health check routes
import { Request, Response, Router } from 'express';
import { testDatabaseConnection } from '../db/pool';

const router = Router();

interface HealthResponse {
    ok: boolean;
    db?: 'up' | 'down';
    timestamp: string;
}

router.get('/health', async (req: Request, res: Response) => {
    try {
        const dbStatus = await testDatabaseConnection();

        const response: HealthResponse = {
            ok: dbStatus,
            db: dbStatus ? 'up' : 'down',
            timestamp: new Date().toISOString(),
        };

        const statusCode = dbStatus ? 200 : 503;
        res.status(statusCode).json(response);
    } catch (error) {
        console.error('Health check error:', error);
        res.status(503).json({
            ok: false,
            db: 'down',
            timestamp: new Date().toISOString(),
        });
    }
});

export default router;
