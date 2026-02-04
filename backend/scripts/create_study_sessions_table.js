const { Pool } = require('pg');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || '5432'),
});

async function createTable() {
  const client = await pool.connect();
  try {
    console.log('Creating study_sessions table...');
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS study_sessions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id),
        goal_id UUID NOT NULL REFERENCES goals(id),
        duration_minutes INTEGER NOT NULL,
        start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        actual_duration_seconds INTEGER,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        deleted_at TIMESTAMP WITH TIME ZONE
      );
    `);
    
    console.log('✅ study_sessions table created successfully');
    
    // Add valid index for performance
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_study_sessions_user_id ON study_sessions(user_id);
    `);
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_study_sessions_goal_id ON study_sessions(goal_id);
    `);

  } catch (err) {
    console.error('❌ Error creating table:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

createTable();
