import { pool } from '../db/pool';

export interface ChatThread {
    id: string;
    user_id: string;
    document_id: string | null;
}

export interface ChatMessageSource {
    docTitle: string;
    excerpt: string;
    pageLabel: string;
}

export interface ChatMessageRecord {
    id: string;
    text: string;
    isUser: boolean;
    timestamp: Date;
    sources?: ChatMessageSource[];
}

export async function getThreadById(userId: string, threadId: string): Promise<ChatThread | null> {
    const res = await pool.query(
        `SELECT id, user_id, document_id
         FROM chat_threads
         WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [threadId, userId]
    );
    return res.rows[0] ?? null;
}

export async function getOrCreateThread(userId: string, documentId: string | null): Promise<ChatThread> {
    const res = await pool.query(
        `SELECT id, user_id, document_id
         FROM chat_threads
         WHERE user_id = $1 AND document_id IS NOT DISTINCT FROM $2 AND deleted_at IS NULL
         ORDER BY created_at DESC
         LIMIT 1`,
        [userId, documentId]
    );

    if (res.rows.length > 0) {
        return res.rows[0];
    }

    const insert = await pool.query(
        `INSERT INTO chat_threads (user_id, document_id, created_at, updated_at)
         VALUES ($1, $2, NOW(), NOW())
         RETURNING id, user_id, document_id`,
        [userId, documentId]
    );

    return insert.rows[0];
}

export async function addMessage(params: {
    threadId: string;
    text: string;
    isUser: boolean;
    metadata?: Record<string, unknown> | null;
}): Promise<{ id: string }> {
    const res = await pool.query(
        `INSERT INTO chat_messages (thread_id, text, is_user, metadata, timestamp, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW(), NOW())
         RETURNING id`,
        [params.threadId, params.text, params.isUser, params.metadata ?? null]
    );
    return res.rows[0];
}

export async function addMessageSources(params: {
    messageId: string;
    documentId: string;
    sources: Array<{ chunkId?: string; excerpt: string; pageLabel: string }>;
}): Promise<void> {
    if (params.sources.length === 0) {
        return;
    }

    const values: Array<string | null> = [];
    const placeholders: string[] = [];
    let index = 1;

    params.sources.forEach((source) => {
        placeholders.push(
            `($${index++}, $${index++}, $${index++}, $${index++}, $${index++})`
        );
        values.push(
            params.messageId,
            params.documentId,
            source.chunkId ?? null,
            source.excerpt,
            source.pageLabel
        );
    });

    await pool.query(
        `INSERT INTO message_sources (message_id, document_id, chunk_id, excerpt, page_label)
         VALUES ${placeholders.join(',')}`,
        values
    );
}

export async function getThreadMessages(threadId: string): Promise<ChatMessageRecord[]> {
    const res = await pool.query(
        `SELECT
             m.id as message_id,
             m.text,
             m.is_user,
             m.timestamp,
             s.excerpt as source_excerpt,
             s.page_label,
             d.title as doc_title
         FROM chat_messages m
         LEFT JOIN message_sources s ON s.message_id = m.id
         LEFT JOIN documents d ON d.id = s.document_id
         WHERE m.thread_id = $1
         ORDER BY m.timestamp ASC, s.created_at ASC`,
        [threadId]
    );

    const byId = new Map<string, ChatMessageRecord>();

    res.rows.forEach((row) => {
        const id = row.message_id as string;
        const existing = byId.get(id);
        const source = row.source_excerpt
            ? {
                docTitle: row.doc_title as string | null | undefined ?? '',
                excerpt: row.source_excerpt as string,
                pageLabel: row.page_label as string | null | undefined ?? '',
            }
            : null;

        if (!existing) {
            const record: ChatMessageRecord = {
                id,
                text: row.text as string,
                isUser: row.is_user as boolean,
                timestamp: row.timestamp as Date,
                sources: source ? [source] : [],
            };
            byId.set(id, record);
        } else if (source) {
            existing.sources = existing.sources ?? [];
            existing.sources.push(source);
        }
    });

    return Array.from(byId.values());
}
