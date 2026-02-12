// Environment configuration with validation
import dotenv from 'dotenv';

dotenv.config();

interface EnvConfig {
    NODE_ENV: string;
    PORT: number;
    DATABASE_URL: string;
    LLM_BACKEND_URL: string;
    OLLAMA_EMBEDDINGS_URL: string | null;
    EMBEDDING_MODEL: string;
}

function validateEnv(): EnvConfig {
    const nodeEnv = process.env.NODE_ENV || 'development';
    const port = parseInt(process.env.PORT || '3000', 10);

    // DATABASE_URL priority: use it if exists, otherwise construct from PG* vars
    let databaseUrl = process.env.DATABASE_URL;

    if (!databaseUrl) {
        const host = process.env.PGHOST || 'localhost';
        const pgPort = process.env.PGPORT || '5432';
        const database = process.env.PGDATABASE || 'learning_coach_dev';
        const user = process.env.PGUSER || 'postgres';
        const password = process.env.PGPASSWORD || 'postgres';

        databaseUrl = `postgres://${user}:${password}@${host}:${pgPort}/${database}?sslmode=disable`;
    }

    return {
        NODE_ENV: nodeEnv,
        PORT: port,
        DATABASE_URL: databaseUrl,
        LLM_BACKEND_URL: process.env.LLM_BACKEND_URL || 'http://localhost:8000',
        OLLAMA_EMBEDDINGS_URL: process.env.OLLAMA_EMBEDDINGS_URL || null,
        EMBEDDING_MODEL: process.env.EMBEDDING_MODEL || 'nomic-embed-text',
    };
}

export const config = validateEnv();
