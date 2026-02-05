// Health endpoint tests
import { describe } from 'node:test';
import request from 'supertest';
import app from '../app';
import { pool, testDatabaseConnection } from '../db/pool';

describe('Health Endpoint', () => {
    afterAll(async () => {
        await pool.end();
    });

    it('should return 200 when database is up', async () => {
        const dbUp = await testDatabaseConnection();
        if (!dbUp) {
            console.warn('Skipping test: database not available');
            return;
        }

        const response = await request(app).get('/api/v1/health');

        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('ok', true);
        expect(response.body).toHaveProperty('db', 'up');
        expect(response.body).toHaveProperty('timestamp');
    });

    it('should have timestamp in ISO format', async () => {
        const response = await request(app).get('/api/v1/health');

        const timestamp = new Date(response.body.timestamp);
        expect(timestamp).toBeInstanceOf(Date);
        expect(timestamp.toISOString()).toBe(response.body.timestamp);
    });
});
