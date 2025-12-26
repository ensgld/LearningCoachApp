-- migrate:up

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL; -- Active users

-- Goals
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(status);
CREATE INDEX idx_goals_user_status ON goals(user_id, status) WHERE deleted_at IS NULL;

-- Goal Tasks
CREATE INDEX idx_goal_tasks_goal_id ON goal_tasks(goal_id);
CREATE INDEX idx_goal_tasks_position ON goal_tasks(goal_id, position);

-- Study Sessions
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_goal_id ON study_sessions(goal_id);
CREATE INDEX idx_study_sessions_start_time ON study_sessions(start_time DESC);
CREATE INDEX idx_study_sessions_user_start ON study_sessions(user_id, start_time DESC);

-- Quizzes
CREATE INDEX idx_quizzes_session_id ON quizzes(session_id);
CREATE INDEX idx_quizzes_user_id ON quizzes(user_id);

-- Quiz Questions
CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);
CREATE INDEX idx_quiz_questions_position ON quiz_questions(quiz_id, position);

-- Quiz Attempts
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);

-- Kaizen Check-ins
CREATE INDEX idx_kaizen_user_id ON kaizen_checkins(user_id);
CREATE INDEX idx_kaizen_date ON kaizen_checkins(checkin_date DESC);
CREATE INDEX idx_kaizen_user_date ON kaizen_checkins(user_id, checkin_date DESC);

-- Documents
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_uploaded_at ON documents(uploaded_at DESC);

-- Document Chunks (CRITICAL for RAG)
CREATE INDEX idx_document_chunks_document_id ON document_chunks(document_id);
CREATE INDEX idx_document_chunks_index ON document_chunks(document_id, chunk_index);

-- **pgvector HNSW index for fast similarity search**
-- HNSW (Hierarchical Navigable Small World) for approximate nearest neighbor
-- m: max connections per layer (16 is good default)
-- ef_construction: quality vs speed tradeoff (64 is balanced)
CREATE INDEX idx_document_chunks_embedding ON document_chunks 
USING hnsw (embedding vector_cosine_ops) 
WITH (m = 16, ef_construction = 64);

COMMENT ON INDEX idx_document_chunks_embedding IS 'HNSW index for fast cosine similarity search on embeddings';

-- Chat Threads
CREATE INDEX idx_chat_threads_user_id ON chat_threads(user_id);
CREATE INDEX idx_chat_threads_document_id ON chat_threads(document_id);
CREATE INDEX idx_chat_threads_updated_at ON chat_threads(updated_at DESC);

-- Chat Messages
CREATE INDEX idx_chat_messages_thread_id ON chat_messages(thread_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp);

-- Message Sources
CREATE INDEX idx_message_sources_message_id ON message_sources(message_id);
CREATE INDEX idx_message_sources_document_id ON message_sources(document_id);

-- User Stats
CREATE INDEX idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX idx_user_stats_level ON user_stats(current_level DESC);

-- User Inventory
CREATE INDEX idx_user_inventory_user_id ON user_inventory(user_id);
CREATE INDEX idx_user_inventory_item_id ON user_inventory(item_id);
CREATE INDEX idx_user_inventory_equipped ON user_inventory(user_id, is_equipped) WHERE is_equipped = TRUE;


-- migrate:down

DROP INDEX IF EXISTS idx_user_inventory_equipped;
DROP INDEX IF EXISTS idx_user_inventory_item_id;
DROP INDEX IF EXISTS idx_user_inventory_user_id;
DROP INDEX IF EXISTS idx_user_stats_level;
DROP INDEX IF EXISTS idx_user_stats_user_id;
DROP INDEX IF EXISTS idx_message_sources_document_id;
DROP INDEX IF EXISTS idx_message_sources_message_id;
DROP INDEX IF EXISTS idx_chat_messages_timestamp;
DROP INDEX IF EXISTS idx_chat_messages_thread_id;
DROP INDEX IF EXISTS idx_chat_threads_updated_at;
DROP INDEX IF EXISTS idx_chat_threads_document_id;
DROP INDEX IF EXISTS idx_chat_threads_user_id;
DROP INDEX IF EXISTS idx_document_chunks_embedding;
DROP INDEX IF EXISTS idx_document_chunks_index;
DROP INDEX IF EXISTS idx_document_chunks_document_id;
DROP INDEX IF EXISTS idx_documents_uploaded_at;
DROP INDEX IF EXISTS idx_documents_status;
DROP INDEX IF EXISTS idx_documents_user_id;
DROP INDEX IF EXISTS idx_kaizen_user_date;
DROP INDEX IF EXISTS idx_kaizen_date;
DROP INDEX IF EXISTS idx_kaizen_user_id;
DROP INDEX IF EXISTS idx_quiz_attempts_user_id;
DROP INDEX IF EXISTS idx_quiz_attempts_quiz_id;
DROP INDEX IF EXISTS idx_quiz_questions_position;
DROP INDEX IF EXISTS idx_quiz_questions_quiz_id;
DROP INDEX IF EXISTS idx_quizzes_user_id;
DROP INDEX IF EXISTS idx_quizzes_session_id;
DROP INDEX IF EXISTS idx_study_sessions_user_start;
DROP INDEX IF EXISTS idx_study_sessions_start_time;
DROP INDEX IF EXISTS idx_study_sessions_goal_id;
DROP INDEX IF EXISTS idx_study_sessions_user_id;
DROP INDEX IF EXISTS idx_goal_tasks_position;
DROP INDEX IF EXISTS idx_goal_tasks_goal_id;
DROP INDEX IF EXISTS idx_goals_user_status;
DROP INDEX IF EXISTS idx_goals_status;
DROP INDEX IF EXISTS idx_goals_user_id;
DROP INDEX IF EXISTS idx_users_deleted_at;
DROP INDEX IF EXISTS idx_users_email;
