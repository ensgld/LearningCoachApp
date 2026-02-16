import { NextFunction, Response, Router } from 'express';
import fs from 'fs';
import multer from 'multer';
import path from 'path';
import { BadRequestError, ConflictError } from '../common/errors';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as chatService from '../services/chat.service';
import * as documentService from '../services/document.service';
import * as documentRagService from '../services/document_rag.service';

const router = Router();
const uploadDir = 'uploads';

// Ensure upload directory exists
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        // Unique filename: timestamp-originalName
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// Development-only reindex (no auth)
router.post('/:id/reindex-dev', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        if (process.env.NODE_ENV !== 'development') {
            throw new BadRequestError('Sadece development ortamında kullanılabilir.');
        }

        const docId = req.params.id;
        const resDoc = await documentService.getDocumentById(docId);

        if (!resDoc.file_path || !fs.existsSync(resDoc.file_path)) {
            throw new BadRequestError('Dosya bulunamadı. Lütfen dokümanı yeniden yükleyin.');
        }

        res.status(202).json({ status: 'queued' });

        void documentRagService
            .indexDocument({
                documentId: resDoc.id,
                filePath: path.resolve(resDoc.file_path),
                mimeType: resDoc.mime_type || '',
            })
            .catch((err) => console.error('Document reindex failed:', err));
    } catch (e) {
        next(e);
    }
});

// Middleware
router.use(authMiddleware);

// POST /documents - Upload file
router.post('/', upload.single('file'), async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        if (!req.file) {
            throw new BadRequestError('No file uploaded');
        }

        const userId = req.user!.userId;
        const title = req.body.title || req.file.originalname;

        const doc = await documentService.createDocument(userId, {
            title: title,
            filePath: req.file.path,
            fileType: req.file.mimetype,
            fileSize: req.file.size
        });

        res.status(201).json({ document: doc });

        void documentRagService
            .indexDocument({
                documentId: doc.id,
                filePath: path.resolve(req.file.path),
                mimeType: req.file.mimetype,
            })
            .catch((err) => console.error('Document indexing failed:', err));
    } catch (e) {
        // Cleanup file if DB insert fails?
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        next(e);
    }
});

// GET /documents - List documents
router.get('/', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const documents = await documentService.getDocuments(userId);
        res.json({ documents });
    } catch (e) {
        next(e);
    }
});

// GET /documents/:id - Document detail
router.get('/:id', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const document = await documentService.getDocument(userId, req.params.id);
        res.json({ document });
    } catch (e) {
        next(e);
    }
});

// POST /documents/:id/chat - Ask document
router.post('/:id/chat', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const doc = await documentService.getDocument(userId, req.params.id);

        if (doc.status !== 'ready') {
            throw new ConflictError('Doküman işleniyor. Lütfen biraz bekleyin.');
        }

        if (!req.body?.message || typeof req.body.message !== 'string') {
            throw new BadRequestError('message alanı zorunludur');
        }

        const thread = await chatService.getOrCreateThread(userId, doc.id);

        await chatService.addMessage({
            threadId: thread.id,
            text: req.body.message,
            isUser: true,
        });

        const result = await documentRagService.chatWithDocument({
            documentId: doc.id,
            question: req.body.message,
            docTitle: doc.title,
        });

        const aiMessage = await chatService.addMessage({
            threadId: thread.id,
            text: result.answer,
            isUser: false,
        });

        if (result.sources && result.sources.length > 0) {
            await chatService.addMessageSources({
                messageId: aiMessage.id,
                documentId: doc.id,
                sources: result.sources.map((source) => ({
                    chunkId: source.chunkId,
                    excerpt: source.excerpt,
                    pageLabel: source.pageLabel,
                })),
            });
        }

        res.json({
            answer: result.answer,
            sources: result.sources,
            threadId: thread.id,
        });
    } catch (e) {
        next(e);
    }
});

// GET /documents/:id/chat/history - Document chat history
router.get('/:id/chat/history', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const doc = await documentService.getDocument(userId, req.params.id);

        const thread = await chatService.getOrCreateThread(userId, doc.id);
        const messages = await chatService.getThreadMessages(thread.id);

        res.json({ threadId: thread.id, messages });
    } catch (e) {
        next(e);
    }
});

// POST /documents/:id/reindex - Reprocess document
router.post('/:id/reindex', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        const doc = await documentService.getDocument(userId, req.params.id);

        if (!doc.file_path || !fs.existsSync(doc.file_path)) {
            throw new BadRequestError('Dosya bulunamadı. Lütfen dokümanı yeniden yükleyin.');
        }

        res.status(202).json({ status: 'queued' });

        void documentRagService
            .indexDocument({
                documentId: doc.id,
                filePath: path.resolve(doc.file_path),
                mimeType: doc.mime_type || '',
            })
            .catch((err) => console.error('Document reindex failed:', err));
    } catch (e) {
        next(e);
    }
});

// DELETE /documents/:id
router.delete('/:id', async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.userId;
        await documentService.deleteDocument(userId, req.params.id);
        res.status(204).send();
    } catch (e) {
        next(e);
    }
});

export default router;
