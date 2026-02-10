// Debug routes (development only)
import { Request, Response, Router } from 'express';
import fs from 'fs';
import path from 'path';
import { BadRequestError } from '../common/errors';
import { pool } from '../db/pool';
import * as documentService from '../services/document.service';
import * as documentRagService from '../services/document_rag.service';

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

// POST /debug/documents/:id/reindex - Dev reindex without auth
router.post('/debug/documents/:id/reindex', async (req: Request, res: Response, next: (err?: Error) => void) => {
    try {
        if (process.env.NODE_ENV !== 'development') {
            return res.status(404).json({ error: 'Not found' });
        }

        const docId = req.params.id;
        const doc = await documentService.getDocumentById(docId);

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
        next(e as Error);
    }
});

export default router;
