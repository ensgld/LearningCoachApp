-- migrate:up
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enable vector operations for RAG (pgvector)
-- Note: pgvector extension must be installed on the PostgreSQL server
-- Installation: https://github.com/pgvector/pgvector
CREATE EXTENSION IF NOT EXISTS "vector";

-- migrate:down
DROP EXTENSION IF EXISTS "vector";
DROP EXTENSION IF EXISTS "pgcrypto";
