// Environment configuration with validation
import dotenv from 'dotenv';

dotenv.config();

interface EnvConfig {
    NODE_ENV: string;
    PORT: number;
    DATABASE_URL: string;
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
    };
}

export const config = validateEnv();
