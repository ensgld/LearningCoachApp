import { NextFunction, Response, Router } from 'express';
import { BadRequestError } from '../common/errors';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as chatService from '../services/chat.service';
import { askCoach } from '../services/llm_backend.service';

const router = Router();

router.use(authMiddleware);

// POST /chat - general coach chat
router.post('/chat', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const { message, threadId } = req.body ?? {};

        if (!message || typeof message !== 'string') {
            throw new BadRequestError('message alanı zorunludur');
        }

        const thread = threadId
            ? await chatService.getThreadById(userId, threadId)
            : await chatService.getOrCreateThread(userId, null);

        if (!thread) {
            throw new BadRequestError('Geçersiz threadId');
        }

        await chatService.addMessage({
            threadId: thread.id,
            text: message,
            isUser: true,
        });

        const answer = await askCoach(message);

        await chatService.addMessage({
            threadId: thread.id,
            text: answer,
            isUser: false,
        });

        res.json({ answer, threadId: thread.id });
    } catch (e) {
        next(e);
    }
});

// GET /chat/history - general coach chat history
router.get('/chat/history', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const threadId = typeof req.query.threadId === 'string' ? req.query.threadId : null;

        const thread = threadId
            ? await chatService.getThreadById(userId, threadId)
            : await chatService.getOrCreateThread(userId, null);

        if (!thread) {
            return res.json({ threadId: null, messages: [] });
        }

        const messages = await chatService.getThreadMessages(thread.id);
        res.json({ threadId: thread.id, messages });
    } catch (e) {
        next(e);
    }
});

export default router;
