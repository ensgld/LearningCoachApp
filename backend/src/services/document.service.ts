import fs from 'fs';
import { NotFoundError } from '../common/errors';
import { pool } from '../db/pool';

export interface CreateDocumentDTO {
    title: string;
    filePath: string;
    fileType: string;
    fileSize: number;
}

export async function createDocument(userId: string, dto: CreateDocumentDTO) {
    const res = await pool.query(
        `INSERT INTO documents (user_id, title, file_path, mime_type, file_size_bytes)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [userId, dto.title, dto.filePath, dto.fileType, dto.fileSize]
    );
    return res.rows[0];
}

export async function getDocuments(userId: string) {
    const res = await pool.query(
        `SELECT * FROM documents 
         WHERE user_id = $1 AND deleted_at IS NULL
         ORDER BY uploaded_at DESC`,
        [userId]
    );
    // Map snake_case to camelCase for frontend consistency if needed, 
    // but typically we keep it consistent or map in repository.
    // Let's return raw rows and handle mapping in frontend repo.
    return res.rows;
}

export async function getDocument(userId: string, docId: string) {
    const res = await pool.query(
        `SELECT * FROM documents WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [docId, userId]
    );
    if (res.rows.length === 0) throw new NotFoundError('Document not found');
    return res.rows[0];
}

export async function getDocumentById(docId: string) {
    const res = await pool.query(
        `SELECT * FROM documents WHERE id = $1 AND deleted_at IS NULL`,
        [docId]
    );
    if (res.rows.length === 0) throw new NotFoundError('Document not found');
    return res.rows[0];
}

export async function deleteDocument(userId: string, docId: string) {
    const docRes = await pool.query(
        `SELECT * FROM documents WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [docId, userId]
    );

    if (docRes.rows.length === 0) throw new NotFoundError('Document not found');
    const doc = docRes.rows[0];

    // Soft delete in DB
    await pool.query(
        `UPDATE documents SET deleted_at = NOW() WHERE id = $1`,
        [docId]
    );

    // Optional: Delete file from filesystem?
    // For now, let's keep it or delete it. Better to keep for soft delete logic 
    // or properly delete if we want to save space. User said "silebilsin".
    // I will attempt to delete the file to save space.
    try {
        if (doc.file_path && fs.existsSync(doc.file_path)) {
            fs.unlinkSync(doc.file_path);
        }
    } catch (e) {
        console.error('Failed to delete file from disk:', e);
    }
}
