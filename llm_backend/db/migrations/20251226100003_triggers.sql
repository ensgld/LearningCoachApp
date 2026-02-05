-- migrate:up

-- ============================================================================
-- TRIGGERS for updated_at automation
-- ============================================================================

-- Generic trigger function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_goals_updated_at BEFORE UPDATE ON goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_goal_tasks_updated_at BEFORE UPDATE ON goal_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_study_sessions_updated_at BEFORE UPDATE ON study_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_quizzes_updated_at BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_quiz_questions_updated_at BEFORE UPDATE ON quiz_questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_quiz_attempts_updated_at BEFORE UPDATE ON quiz_attempts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_kaizen_checkins_updated_at BEFORE UPDATE ON kaizen_checkins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_documents_updated_at BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_document_chunks_updated_at BEFORE UPDATE ON document_chunks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_chat_threads_updated_at BEFORE UPDATE ON chat_threads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_chat_messages_updated_at BEFORE UPDATE ON chat_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_user_stats_updated_at BEFORE UPDATE ON user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_inventory_items_updated_at BEFORE UPDATE ON inventory_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_user_inventory_updated_at BEFORE UPDATE ON user_inventory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- migrate:down

DROP TRIGGER IF EXISTS trigger_user_inventory_updated_at ON user_inventory;
DROP TRIGGER IF EXISTS trigger_inventory_items_updated_at ON inventory_items;
DROP TRIGGER IF EXISTS trigger_user_stats_updated_at ON user_stats;
DROP TRIGGER IF EXISTS trigger_chat_messages_updated_at ON chat_messages;
DROP TRIGGER IF EXISTS trigger_chat_threads_updated_at ON chat_threads;
DROP TRIGGER IF EXISTS trigger_document_chunks_updated_at ON document_chunks;
DROP TRIGGER IF EXISTS trigger_documents_updated_at ON documents;
DROP TRIGGER IF EXISTS trigger_kaizen_checkins_updated_at ON kaizen_checkins;
DROP TRIGGER IF EXISTS trigger_quiz_attempts_updated_at ON quiz_attempts;
DROP TRIGGER IF EXISTS trigger_quiz_questions_updated_at ON quiz_questions;
DROP TRIGGER IF EXISTS trigger_quizzes_updated_at ON quizzes;
DROP TRIGGER IF EXISTS trigger_study_sessions_updated_at ON study_sessions;
DROP TRIGGER IF EXISTS trigger_goal_tasks_updated_at ON goal_tasks;
DROP TRIGGER IF EXISTS trigger_goals_updated_at ON goals;
DROP TRIGGER IF EXISTS trigger_users_updated_at ON users;

DROP FUNCTION IF EXISTS update_updated_at_column();
