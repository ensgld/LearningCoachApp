-- migrate:up

-- ============================================================================
-- USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    is_guest BOOLEAN NOT NULL DEFAULT FALSE,
    password_hash VARCHAR(255), -- NULL for guest/social users
    refresh_token_hash VARCHAR(255), -- Hashed refresh token for security
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ, -- Soft delete
    last_login_at TIMESTAMPTZ,
    
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

COMMENT ON TABLE users IS 'Stores user authentication and profile information';
COMMENT ON COLUMN users.is_guest IS 'Guest users have limited features';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt hashed password, NULL for social/guest login';


-- ============================================================================
-- GOALS & TASKS
-- ============================================================================

CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    progress NUMERIC(3, 2) NOT NULL DEFAULT 0.00, -- 0.00 to 1.00
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT progress_range CHECK (progress >= 0.00 AND progress <= 1.00),
    CONSTRAINT status_values CHECK (status IN ('active', 'completed'))
);

COMMENT ON TABLE goals IS 'User learning goals';
COMMENT ON COLUMN goals.progress IS 'Goal completion progress (0.0 to 1.0)';

CREATE TABLE goal_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    position INTEGER NOT NULL DEFAULT 0, -- For ordering tasks
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE goal_tasks IS 'Sub-tasks for each goal';


-- ============================================================================
-- STUDY SESSIONS
-- ============================================================================

CREATE TABLE study_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Planned vs Actual
    duration_minutes INTEGER NOT NULL, -- Planned duration
    actual_duration_seconds INTEGER, -- Actual duration (NULL if not completed)
    
    -- Timing
    start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_time TIMESTAMPTZ,
    
    -- Quiz score (set after quiz completion)
    quiz_score INTEGER, -- 0-100
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT duration_positive CHECK (duration_minutes > 0),
    CONSTRAINT actual_duration_positive CHECK (actual_duration_seconds IS NULL OR actual_duration_seconds >= 0),
    CONSTRAINT quiz_score_range CHECK (quiz_score IS NULL OR (quiz_score >= 0 AND quiz_score <= 100))
);

COMMENT ON TABLE study_sessions IS 'Study session tracking (Pomodoro-style)';
COMMENT ON COLUMN study_sessions.actual_duration_seconds IS 'Actual time studied, NULL if session incomplete';


-- ============================================================================
-- QUIZ SYSTEM
-- ============================================================================

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES study_sessions(id) ON DELETE CASCADE, -- Can be NULL for standalone quizzes
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_id UUID REFERENCES goals(id) ON DELETE SET NULL, -- Context for quiz generation
    
    title VARCHAR(500),
    total_questions INTEGER NOT NULL DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE quizzes IS 'Generated quizzes for study sessions or standalone';

CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of options: ["opt1", "opt2", "opt3", "opt4"]
    correct_answer_index INTEGER NOT NULL, -- 0-based index of correct option
    
    position INTEGER NOT NULL DEFAULT 0, -- For ordering questions
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT correct_answer_valid CHECK (correct_answer_index >= 0)
);

COMMENT ON TABLE quiz_questions IS 'Questions for each quiz';
COMMENT ON COLUMN quiz_questions.correct_answer_index IS 'Index of correct answer in options array (0-based)';
COMMENT ON COLUMN quiz_questions.options IS 'JSON array of answer options';

CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    score INTEGER NOT NULL, -- 0-100
    answers JSONB NOT NULL, -- Array of user answers: [{"question_id": "...", "selected_index": 2}, ...]
    
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT score_range CHECK (score >= 0 AND score <= 100)
);

COMMENT ON TABLE quiz_attempts IS 'User attempts at quizzes';
COMMENT ON COLUMN quiz_attempts.answers IS 'JSON array of user answers with question_id and selected_index';


-- ============================================================================
-- KAIZEN CHECK-INS
-- ============================================================================

CREATE TABLE kaizen_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    did_yesterday TEXT NOT NULL,
    blocked_by TEXT NOT NULL,
    do_today TEXT NOT NULL,
    
    checkin_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    UNIQUE(user_id, checkin_date) -- One check-in per day per user
);

COMMENT ON TABLE kaizen_checkins IS 'Daily Kaizen reflections for continuous improvement';


-- ============================================================================
-- DOCUMENTS & RAG
-- ============================================================================

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    title VARCHAR(500) NOT NULL,
    summary TEXT,
    file_path VARCHAR(1000), -- Cloud storage path (S3, GCS, etc.)
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    
    status VARCHAR(20) NOT NULL DEFAULT 'processing',
    error_message TEXT, -- If status = 'failed'
    
    -- Indexing metadata
    total_chunks INTEGER DEFAULT 0,
    indexed_at TIMESTAMPTZ, -- When indexing completed
    
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT status_values CHECK (status IN ('processing', 'ready', 'failed'))
);

COMMENT ON TABLE documents IS 'User uploaded documents for RAG system';
COMMENT ON COLUMN documents.status IS 'processing: being indexed, ready: available for chat, failed: error during processing';

CREATE TABLE document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    
    chunk_text TEXT NOT NULL,
    chunk_index INTEGER NOT NULL, -- Chunk order in document
    
    -- Metadata
    metadata JSONB, -- {"page": 5, "section_title": "Introduction", "start_char": 120, "end_char": 520}
    
    -- Embedding vector (dimension configurable, typically 768 or 1536)
    embedding vector(768), -- OpenAI ada-002: 1536, sentence-transformers: 768
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(document_id, chunk_index)
);

COMMENT ON TABLE document_chunks IS 'Document chunks with embeddings for RAG retrieval';
COMMENT ON COLUMN document_chunks.embedding IS 'Vector embedding for semantic search (dimension: 768)';
COMMENT ON COLUMN document_chunks.metadata IS 'JSON metadata: page, section_title, char positions, etc.';


-- ============================================================================
-- CHAT (COACH MESSAGES)
-- ============================================================================

CREATE TABLE chat_threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE, -- NULL for general coach chat
    
    title VARCHAR(500), -- Auto-generated or user-defined
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE chat_threads IS 'Chat conversations (document-based or general coach)';

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id UUID NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,
    
    text TEXT NOT NULL,
    is_user BOOLEAN NOT NULL, -- TRUE: user message, FALSE: AI message
    
    -- Optional metadata (action cards, suggestions)
    metadata JSONB, -- {"action_card": "schedule_session", "suggestions": ["tip1", "tip2"]}
    
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE chat_messages IS 'Individual messages in chat threads';
COMMENT ON COLUMN chat_messages.metadata IS 'JSONB for action cards, suggestions, or other message metadata';

CREATE TABLE message_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_id UUID REFERENCES document_chunks(id) ON DELETE SET NULL,
    
    excerpt TEXT NOT NULL, -- Citation text
    page_label VARCHAR(50), -- "Page 15", "Section 3.2"
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE message_sources IS 'Source citations for AI messages (RAG references)';


-- ============================================================================
-- GAMIFICATION
-- ============================================================================

CREATE TABLE user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    current_level INTEGER NOT NULL DEFAULT 1,
    current_xp INTEGER NOT NULL DEFAULT 0,
    total_gold INTEGER NOT NULL DEFAULT 100, -- Starting gold
    
    avatar_stage VARCHAR(20) NOT NULL DEFAULT 'seed',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT level_positive CHECK (current_level > 0),
    CONSTRAINT xp_non_negative CHECK (current_xp >= 0),
    CONSTRAINT gold_non_negative CHECK (total_gold >= 0),
    CONSTRAINT avatar_stage_values CHECK (avatar_stage IN ('seed', 'sprout', 'bloom', 'tree', 'forest'))
);

COMMENT ON TABLE user_stats IS 'User gamification stats: level, XP, gold, avatar evolution';

CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    gold_cost INTEGER NOT NULL,
    asset_path VARCHAR(500) NOT NULL, -- Path to image asset
    
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- For seasonal/limited items
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT category_values CHECK (category IN ('pot', 'background', 'companion')),
    CONSTRAINT gold_cost_positive CHECK (gold_cost >= 0)
);

COMMENT ON TABLE inventory_items IS 'Global inventory pool (shop items)';

CREATE TABLE user_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    
    is_equipped BOOLEAN NOT NULL DEFAULT FALSE,
    
    purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(user_id, item_id) -- User can own each item once
);

COMMENT ON TABLE user_inventory IS 'Items purchased and equipped by users';


-- migrate:down

DROP TABLE IF EXISTS user_inventory CASCADE;
DROP TABLE IF EXISTS inventory_items CASCADE;
DROP TABLE IF EXISTS user_stats CASCADE;
DROP TABLE IF EXISTS message_sources CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_threads CASCADE;
DROP TABLE IF EXISTS document_chunks CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS kaizen_checkins CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS study_sessions CASCADE;
DROP TABLE IF EXISTS goal_tasks CASCADE;
DROP TABLE IF EXISTS goals CASCADE;
DROP TABLE IF EXISTS users CASCADE;
