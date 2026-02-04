import { pool } from '../src/db/pool';

async function createDocumentsTable() {
    const client = await pool.connect();
    try {
        console.log('Creating documents table...');

        await client.query(`
            CREATE TABLE IF NOT EXISTS documents (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                title TEXT NOT NULL,
                file_path TEXT NOT NULL,
                file_type TEXT,
                file_size INTEGER,
                uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                status TEXT DEFAULT 'ready', -- ready, processing, failed
                deleted_at TIMESTAMP WITH TIME ZONE
            );
        `);

        // Index for faster queries by user
        await client.query(`
            CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
        `);

        console.log('✅ documents table created successfully');
    } catch (e) {
        console.error('❌ Error creating documents table:', e);
    } finally {
        client.release();
        await pool.end();
    }
}

createDocumentsTable();
