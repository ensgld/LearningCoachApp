// Debug routes (development only)
import { Request, Response, Router } from 'express';
import { pool } from '../db/pool';

const router = Router();

// GET /debug/db-info - Show current database connection info
router.get('/debug/db-info', async (req: Request, res: Response) => {
    if (process.env.NODE_ENV !== 'development') {
        return res.status(404).json({ error: 'Not found' });
    }

    try {
        const result = await pool.query(`
            SELECT 
                current_database() as database,
                current_user as user,
                inet_server_addr() as server_addr,
                version() as postgres_version
        `);

        res.json({
            connection: result.rows[0],
            env: {
                DATABASE_URL: process.env.DATABASE_URL?.replace(/:[^:]*@/, ':****@'), // Hide password
                NODE_ENV: process.env.NODE_ENV,
            },
        });
    } catch (error) {
        res.status(500).json({ error: 'Database query failed', message: (error as Error).message });
    }
});

export default router;
