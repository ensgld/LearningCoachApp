// PostgreSQL connection pool
import { Pool, PoolConfig } from 'pg';
import { config } from '../config/env';

const poolConfig: PoolConfig = {
    connectionString: config.DATABASE_URL,
    max: 20, // Maximum number of clients in the pool
    idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
    connectionTimeoutMillis: 5000, // Return an error after 5 seconds if connection could not be established
};

export const pool = new Pool(poolConfig);

// Test query to check DB connectivity
export async function testDatabaseConnection(): Promise<boolean> {
    try {
        const result = await pool.query('SELECT 1 as test');
        return result.rows[0].test === 1;
    } catch (error) {
        console.error('Database connection test failed:', error);
        return false;
    }
}

// Graceful shutdown
export async function closeDatabasePool(): Promise<void> {
    await pool.end();
}
