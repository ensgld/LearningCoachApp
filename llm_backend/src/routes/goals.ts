import { NextFunction, Response, Router } from 'express';
import { BadRequestError } from '../common/errors';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as goalService from '../services/goal.service';

const router = Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// GET /goals - List all goals
router.get('/', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const goals = await goalService.getGoals(req.user!.userId);
        res.json({ goals });
    } catch (e) {
        next(e);
    }
});

// POST /goals - Create a goal
router.post('/', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const { title, description, tasks } = req.body;
        if (!title) throw new BadRequestError('Title is required');

        const goal = await goalService.createGoal(req.user!.userId, {
            title,
            description,
            tasks
        });
        res.status(201).json({ goal });
    } catch (e) {
        next(e);
    }
});

// GET /goals/:id - Get specific goal
router.get('/:id', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const goal = await goalService.getGoal(req.user!.userId, req.params.id);
        res.json({ goal });
    } catch (e) {
        next(e);
    }
});

// PATCH /goals/:id - Update goal
router.patch('/:id', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const goal = await goalService.updateGoal(req.user!.userId, req.params.id, req.body);
        res.json({ goal });
    } catch (e) {
        next(e);
    }
});

// DELETE /goals/:id - Delete goal
router.delete('/:id', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        await goalService.deleteGoal(req.user!.userId, req.params.id);
        res.status(204).send();
    } catch (e) {
        next(e);
    }
});

// POST /goals/:id/tasks - Add task
router.post('/:id/tasks', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const { title } = req.body;
        if (!title) throw new BadRequestError('Task title is required');

        const goal = await goalService.addTask(req.user!.userId, req.params.id, { title });
        res.status(201).json({ goal });
    } catch (e) {
        next(e);
    }
});

// PATCH /goals/:id/tasks/:taskId - Update task
router.patch('/:id/tasks/:taskId', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const goal = await goalService.updateTask(
            req.user!.userId,
            req.params.id,
            req.params.taskId,
            req.body
        );
        res.json({ goal });
    } catch (e) {
        next(e);
    }
});

// DELETE /goals/:id/tasks/:taskId - Delete task
router.delete('/:id/tasks/:taskId', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const goal = await goalService.deleteTask(
            req.user!.userId,
            req.params.id,
            req.params.taskId
        );
        res.json({ goal });
    } catch (e) {
        next(e);
    }
});

export default router;
