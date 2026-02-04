import { NextFunction, Response, Router } from 'express';
import fs from 'fs';
import multer from 'multer';
import path from 'path';
import { BadRequestError } from '../common/errors';
import { authMiddleware, AuthRequest } from '../middleware/auth.middleware';
import * as documentService from '../services/document.service';

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
