import crypto from 'crypto';
import fs from 'fs';
import { htmlToText } from 'html-to-text';
import mammoth from 'mammoth';
import os from 'os';
import path from 'path';
import pdfParse from 'pdf-parse';
import { fromPath as pdfToPic } from 'pdf2pic';
import { createWorker } from 'tesseract.js';
import textract from 'textract';
import xlsx from 'xlsx';
import { pool } from '../db/pool';
import { answerWithContext, embedTexts } from './llm_backend.service';

const CHUNK_WORDS = 150;
const CHUNK_OVERLAP = 20;
const TOP_K = 5;
const EMBEDDING_BATCH_SIZE = 1;
const MAX_EMBEDDING_CHARS = 500;
const EMBEDDING_RETRIES = 3;
const EMBEDDING_RETRY_DELAY_MS = 750;
const MIN_TEXT_LENGTH = 50;
const OCR_MAX_PAGES = parseInt(process.env.OCR_MAX_PAGES || '5', 10);
const OCR_LANG = process.env.OCR_LANG || 'eng';
const SUMMARY_MAX_CHARS = 3000;

export interface RagSource {
    chunkId: string;
    excerpt: string;
    pageLabel: string;
    docTitle: string;
}

export async function indexDocument(params: {
    documentId: string;
    filePath: string;
    mimeType: string;
}): Promise<void> {
    try {
        const existingDoc = await pool.query(
            'SELECT summary FROM documents WHERE id = $1',
            [params.documentId]
        );
        const existingSummary = existingDoc.rows[0]?.summary as string | null | undefined;

        const text = await extractText(params.filePath, params.mimeType);
        if (!text || text.trim().length === 0) {
            await markDocumentFailed(params.documentId, 'Doküman metni çıkarılamadı.');
            return;
        }

        const chunks = chunkText(text);
        if (chunks.length === 0) {
            await markDocumentFailed(params.documentId, 'Doküman parçalara ayrılamadı.');
            return;
        }

        const totalChunks = chunks.length;

        const summary = existingSummary && existingSummary.trim().length > 0
            ? existingSummary
            : await generateSummary(chunks);

        await pool.query('DELETE FROM document_chunks WHERE document_id = $1', [params.documentId]);
        await pool.query(
            `UPDATE documents
             SET status = 'processing', total_chunks = $2, processing_progress = 0.00, error_message = NULL, summary = $3, content_text = $4
             WHERE id = $1`,
            [params.documentId, totalChunks, summary, text]
        );

        let processed = 0;

        for (let start = 0; start < chunks.length; start += EMBEDDING_BATCH_SIZE) {
            const batch = chunks.slice(start, start + EMBEDDING_BATCH_SIZE);
            let embeddings: number[][] | null = null;
            let lastError: unknown;
            for (let attempt = 1; attempt <= EMBEDDING_RETRIES; attempt += 1) {
                try {
                    embeddings = await embedTexts(batch.map((c) => c.text));
                    lastError = undefined;
                    break;
                } catch (error) {
                    lastError = error;
                    if (attempt < EMBEDDING_RETRIES) {
                        await new Promise((resolve) => setTimeout(resolve, EMBEDDING_RETRY_DELAY_MS * attempt));
                    }
                }
            }
            if (!embeddings || lastError) {
                const message = lastError instanceof Error ? lastError.message : 'Embedding failed';
                await markDocumentFailed(params.documentId, message);
                return;
            }
            if (embeddings.length !== batch.length) {
                await markDocumentFailed(params.documentId, 'Embedding sayısı hatalı.');
                return;
            }

            const values: Array<string | number> = [];
            const placeholders: string[] = [];
            let paramIndex = 1;

            batch.forEach((chunk, index) => {
                const embedding = embeddings[index];
                const vector = `[${embedding.join(',')}]`;

                placeholders.push(
                    `($${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++}, $${paramIndex++}::vector)`
                );
                values.push(
                    params.documentId,
                    chunk.text,
                    chunk.index,
                    JSON.stringify(chunk.metadata),
                    vector
                );
            });

            await pool.query(
                `INSERT INTO document_chunks (document_id, chunk_text, chunk_index, metadata, embedding)
                 VALUES ${placeholders.join(',')}`,
                values
            );

            processed += batch.length;
            const progress = processed / totalChunks;
            await pool.query(
                `UPDATE documents
                 SET processing_progress = $2
                 WHERE id = $1`,
                [params.documentId, progress]
            );
            await new Promise((resolve) => setTimeout(resolve, 150));
        }

        await pool.query(
            `UPDATE documents
             SET status = 'ready', total_chunks = $2, indexed_at = NOW(), error_message = NULL, processing_progress = 1.00, summary = $3, content_text = $4
             WHERE id = $1`,
            [params.documentId, totalChunks, summary, text]
        );
    } catch (e) {
        await markDocumentFailed(params.documentId, 'Doküman işlenirken hata oluştu.');
        throw e;
    }
}

export async function chatWithDocument(params: {
    documentId: string;
    question: string;
    docTitle: string;
}): Promise<{ answer: string; sources: RagSource[] }> {
    const [queryEmbedding] = await embedTexts([params.question]);
    const vector = `[${queryEmbedding.join(',')}]`;

    const res = await pool.query(
        `SELECT id, chunk_text, chunk_index, metadata
         FROM document_chunks
         WHERE document_id = $1
         ORDER BY embedding <=> $2::vector
         LIMIT $3`,
        [params.documentId, vector, TOP_K]
    );

    const chunks = res.rows as Array<{
        id: string;
        chunk_text: string;
        chunk_index: number;
        metadata: any;
    }>;

    const context = chunks.map((c) => c.chunk_text).join('\n\n---\n\n');
    const answer = await answerWithContext(params.question, context);

    const sources: RagSource[] = chunks.map((c) => {
        const page = c.metadata?.page;
        const label = page ? `Sayfa ${page}` : `Bölüm ${c.chunk_index + 1}`;
        return {
            chunkId: c.id,
            excerpt: c.chunk_text.slice(0, 240),
            pageLabel: label,
            docTitle: params.docTitle,
        };
    });

    return { answer, sources };
}

async function extractText(filePath: string, mimeType: string): Promise<string> {
    const extension = path.extname(filePath).toLowerCase();
    if (mimeType.includes('pdf') || extension === '.pdf') {
        const data = await pdfParse(fs.readFileSync(filePath));
        const parsed = data.text || '';
        if (parsed.trim().length >= MIN_TEXT_LENGTH) {
            return parsed;
        }
        return ocrPdf(filePath, data.numpages || OCR_MAX_PAGES);
    }

    if (mimeType.includes('word') || extension === '.docx') {
        const result = await mammoth.extractRawText({ path: filePath });
        return result.value;
    }

    if (extension === '.doc' || extension === '.pptx' || extension === '.ppt') {
        return extractWithTextract(filePath);
    }

    if (extension === '.xlsx' || extension === '.xls') {
        return extractSpreadsheet(filePath);
    }

    if (extension === '.md' || extension === '.markdown' || extension === '.txt') {
        return fs.readFileSync(filePath, 'utf-8');
    }

    if (extension === '.csv') {
        return fs.readFileSync(filePath, 'utf-8');
    }

    if (extension === '.html' || extension === '.htm') {
        return htmlToText(fs.readFileSync(filePath, 'utf-8'), { wordwrap: false });
    }

    if (extension === '.rtf') {
        return stripRtfText(fs.readFileSync(filePath, 'utf-8'));
    }

    if (isImage(mimeType, extension)) {
        return ocrImage(filePath);
    }

    return extractWithTextract(filePath);
}

function isImage(mimeType: string, extension: string): boolean {
    if (mimeType.startsWith('image/')) return true;
    return ['.png', '.jpg', '.jpeg', '.bmp', '.tiff', '.tif', '.webp'].includes(extension);
}

async function ocrImage(filePath: string): Promise<string> {
    const worker = await createWorker(OCR_LANG);
    try {
        const result = await worker.recognize(filePath);
        return result.data.text || '';
    } finally {
        await worker.terminate();
    }
}

async function ocrPdf(filePath: string, numPages: number): Promise<string> {
    const maxPages = Math.min(OCR_MAX_PAGES, numPages || OCR_MAX_PAGES);
    const tmpDir = path.join(os.tmpdir(), `lc-ocr-${crypto.randomUUID()}`);
    fs.mkdirSync(tmpDir, { recursive: true });

    const converter = pdfToPic(filePath, {
        density: 150,
        format: 'png',
        saveFilename: 'page',
        savePath: tmpDir,
    });

    const texts: string[] = [];
    for (let page = 1; page <= maxPages; page += 1) {
        const output = await converter(page);
        const pagePath = output.path;
        if (pagePath) {
            texts.push(await ocrImage(pagePath));
        }
    }

    cleanupTmpDir(tmpDir);
    return texts.join('\n\n');
}

function extractSpreadsheet(filePath: string): string {
    const workbook = xlsx.readFile(filePath, { cellDates: true });
    const sheets: string[] = [];
    workbook.SheetNames.forEach((name: string) => {
        const sheet = workbook.Sheets[name];
        const csv = xlsx.utils.sheet_to_csv(sheet);
        if (csv.trim()) {
            sheets.push(`Sheet: ${name}\n${csv}`);
        }
    });
    return sheets.join('\n\n');
}

function stripRtfText(input: string): string {
    return input
        .replace(/\\par[d]?/g, '\n')
        .replace(/\\'[0-9a-fA-F]{2}/g, '')
        .replace(/\\[a-zA-Z]+-?\d* ?/g, '')
        .replace(/[{}]/g, '')
        .replace(/\s{2,}/g, ' ')
        .trim();
}

function extractWithTextract(filePath: string): Promise<string> {
    return new Promise((resolve, reject) => {
        textract.fromFileWithPath(filePath, (error: Error | null, text?: string) => {
            if (error) {
                reject(error);
                return;
            }
            resolve((text || '').toString());
        });
    });
}

async function generateSummary(
    chunks: Array<{ text: string; index: number; metadata: any }>
): Promise<string> {
    if (chunks.length === 0) {
        return '';
    }

    const context = buildSummaryContext(chunks, SUMMARY_MAX_CHARS);
    if (!context.trim()) {
        return '';
    }

    try {
        return await answerWithContext(
            'Dokümanı 5-7 cümlede özetle.',
            context
        );
    } catch (error) {
        console.warn('Summary generation failed:', error);
        return '';
    }
}

function buildSummaryContext(
    chunks: Array<{ text: string; index: number; metadata: any }>,
    maxChars: number
): string {
    const selected: string[] = [];
    let total = 0;

    for (const chunk of chunks) {
        const text = chunk.text.trim();
        if (!text) {
            continue;
        }
        if (total + text.length > maxChars) {
            const remaining = Math.max(0, maxChars - total);
            if (remaining > 0) {
                selected.push(text.slice(0, remaining));
            }
            break;
        }
        selected.push(text);
        total += text.length;
        if (total >= maxChars) {
            break;
        }
    }

    return selected.join('\n\n---\n\n');
}

function cleanupTmpDir(tmpDir: string): void {
    try {
        fs.rmSync(tmpDir, { recursive: true, force: true });
    } catch (error) {
        console.warn('Failed to cleanup temp OCR dir:', error);
    }
}

function chunkText(text: string): Array<{ text: string; index: number; metadata: any }> {
    const words = text.split(/\s+/).filter(Boolean);
    const chunks: Array<{ text: string; index: number; metadata: any }> = [];

    let start = 0;
    let index = 0;

    while (start < words.length) {
        const end = Math.min(start + CHUNK_WORDS, words.length);
        const chunkWords = words.slice(start, end);
        let chunkText = chunkWords.join(' ');
        if (chunkText.length > MAX_EMBEDDING_CHARS) {
            chunkText = chunkText.slice(0, MAX_EMBEDDING_CHARS);
        }
        if (!chunkText.trim()) {
            start += CHUNK_WORDS - CHUNK_OVERLAP;
            continue;
        }
        chunks.push({
            text: chunkText,
            index,
            metadata: {
                start_word: start,
                end_word: end,
            },
        });
        index += 1;
        start += CHUNK_WORDS - CHUNK_OVERLAP;
    }

    return chunks;
}

async function markDocumentFailed(documentId: string, message: string): Promise<void> {
    await pool.query(
        `UPDATE documents
         SET status = 'failed', error_message = $2, processing_progress = 0.00
         WHERE id = $1`,
        [documentId, message]
    );
}
