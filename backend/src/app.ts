// Express application setup
import express, { NextFunction, Request, Response } from 'express';
import { AppError } from './common/errors';
import authRouter from './routes/auth';
import debugRouter from './routes/debug';
import healthRouter from './routes/health';
import quizRouter from './routes/quiz';

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Request logging (simple)
app.use((req: Request, res: Response, next: NextFunction) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
    next();
});

// Routes
app.use('/api/v1/health', healthRouter);
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/quizzes', quizRouter);
app.use('/api/v1/debug', debugRouter);

// 404 handler
app.use((req: Request, res: Response) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} not found`,
    });
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            error: err.message,
            ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
        });
    }

    console.error('Unexpected error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
    });
});

export default app;
