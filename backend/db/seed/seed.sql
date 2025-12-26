-- ============================================================================
-- SEED DATA for Development & Testing
-- ============================================================================
-- Note: This file is NOT a migration. Run manually with: npm run db:seed

-- Seed User
INSERT INTO users (id, email, display_name, is_guest, password_hash, created_at) VALUES
('11111111-1111-1111-1111-111111111111', 'demo@learningcoach.com', 'Demo User', FALSE, 
 '$2b$10$abcdefghijklmnopqrstuvwxyz123456', -- Mock bcrypt hash
 NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- Seed User Stats (Gamification)
INSERT INTO user_stats (user_id, current_level, current_xp, total_gold, avatar_stage) VALUES
('11111111-1111-1111-1111-111111111111', 5, 230, 450, 'seed')
ON CONFLICT (user_id) DO NOTHING;

-- Seed Goals
INSERT INTO goals (id, user_id, title, description, progress, status, created_at) VALUES
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 
 'Flutter İleri Seviye Öğrenme', 'Clean Architecture ve Riverpod ile derinleşme', 
 0.45, 'active', NOW() - INTERVAL '15 days'),
 
('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 
 'İngilizce Kelime Çalışması', 'Her gün 20 yeni akademik kelime', 
 0.20, 'active', NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO NOTHING;

-- Seed Goal Tasks
INSERT INTO goal_tasks (goal_id, title, is_completed, position) VALUES
('22222222-2222-2222-2222-222222222222', 'Riverpod 2.0 dokümanlarını oku', TRUE, 1),
('22222222-2222-2222-2222-222222222222', 'GoRouter deep linking pratik yap', TRUE, 2),
('22222222-2222-2222-2222-222222222222', 'Unit test yazımı öğren', FALSE, 3),

('22222222-2222-2222-2222-222222222223', 'Flashcards set 1', TRUE, 1),
('22222222-2222-2222-2222-222222222223', 'Flashcards set 2', FALSE, 2)
ON CONFLICT DO NOTHING;

-- Seed Study Session
INSERT INTO study_sessions (id, user_id, goal_id, duration_minutes, actual_duration_seconds, start_time, end_time, quiz_score) VALUES
('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 
 '22222222-2222-2222-2222-222222222222', 25, 1480, 
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '25 minutes', 80)
ON CONFLICT (id) DO NOTHING;

-- Seed Quiz
INSERT INTO quizzes (id, session_id, user_id, goal_id, title, total_questions) VALUES
('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 
 '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
 'Flutter Architecture Quiz', 3)
ON CONFLICT (id) DO NOTHING;

-- Seed Quiz Questions
INSERT INTO quiz_questions (quiz_id, question_text, options, correct_answer_index, position) VALUES
('44444444-4444-4444-4444-444444444444', 
 'Riverpod''da provider''lar nasıl tanımlanır?',
 '["@riverpod annotation ile", "Provider.of()", "InheritedWidget ile", "StatefulWidget ile"]',
 0, 1),
 
('44444444-4444-4444-4444-444444444444', 
 'Clean Architecture''da hangi katman UI''a bağımlı değildir?',
 '["Presentation", "Domain", "Data", "Hiçbiri"]',
 1, 2),
 
('44444444-4444-4444-4444-444444444444', 
 'GoRouter''da tam ekran navigasyon için ne kullanılır?',
 '["childNavigatorKey", "parentNavigatorKey", "rootNavigatorKey", "shellNavigatorKey"]',
 1, 3)
ON CONFLICT DO NOTHING;

-- Seed Quiz Attempt
INSERT INTO quiz_attempts (quiz_id, user_id, score, answers, started_at, completed_at) VALUES
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111',
 80, 
 '[
   {"question_id": "q1", "selected_index": 0},
   {"question_id": "q2", "selected_index": 1},
   {"question_id": "q3", "selected_index": 2}
 ]'::jsonb,
 NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '5 minutes')
ON CONFLICT DO NOTHING;

-- Seed Kaizen Check-in
INSERT INTO kaizen_checkins (user_id, did_yesterday, blocked_by, do_today, checkin_date) VALUES
('11111111-1111-1111-1111-111111111111', 
 'Riverpod dokümantasyonu okudum ve örnek proje yaptım',
 'Unit test yazarken mock data oluşturmada zorlandım',
 'Widget testlerini öğreneceğim ve mock provider örneği yapacağım',
 CURRENT_DATE)
ON CONFLICT (user_id, checkin_date) DO NOTHING;

-- Seed Documents
INSERT INTO documents (id, user_id, title, summary, status, file_path, total_chunks, indexed_at, uploaded_at) VALUES
('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111',
 'Flutter_Architecture_Guide.pdf',
 'Flutter uygulamalarında Clean Architecture kullanımı, katmanların ayrılması ve bağımlılık yönetimi hakkında detaylı rehber.',
 'ready', 's3://bucket/docs/flutter_arch.pdf', 12, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

('55555555-5555-5555-5555-555555555556', '11111111-1111-1111-1111-111111111111',
 'Proje_Gereksinimleri_v2.docx',
 'Bitirme projesi için güncel gereksinim listesi ve teslim tarihleri.',
 'processing', 's3://bucket/docs/project_req.docx', 0, NULL, NOW() - INTERVAL '10 minutes')
ON CONFLICT (id) DO NOTHING;

-- Seed Document Chunks (with mock embeddings)
-- Note: In production, embeddings are generated by ML model (OpenAI, sentence-transformers, etc.)
INSERT INTO document_chunks (id, document_id, chunk_text, chunk_index, metadata, embedding) VALUES
('66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555',
 'Clean Architecture bağımlılıkları tersine çevirerek domain katmanını framework''den bağımsız tutar. Bu sayede iş mantığı UI veya database değişikliklerinden etkilenmez.',
 0,
 '{"page": 12, "section_title": "Clean Architecture Principles"}'::jsonb,
 array_fill(0.1::real, ARRAY[768])::vector), -- Mock embedding (replace with real)
 
('66666666-6666-6666-6666-666666666667', '55555555-5555-5555-5555-555555555555',
 'Riverpod, Flutter için compile-time safe state yönetim çözümüdür. Provider pattern üzerine kurulmuştur ve test edilebilirliği artırır.',
 1,
 '{"page": 15, "section_title": "State Management with Riverpod"}'::jsonb,
 array_fill(0.2::real, ARRAY[768])::vector) -- Mock embedding
ON CONFLICT (document_id, chunk_index) DO NOTHING;

-- Seed Chat Thread
INSERT INTO chat_threads (id, user_id, document_id, title) VALUES
('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111',
 '55555555-5555-5555-5555-555555555555', 'Flutter Architecture Soruları')
ON CONFLICT (id) DO NOTHING;

-- Seed Chat Messages
INSERT INTO chat_messages (id, thread_id, text, is_user, timestamp) VALUES
('88888888-8888-8888-8888-888888888888', '77777777-7777-7777-7777-777777777777',
 'Clean Architecture nedir?', TRUE, NOW() - INTERVAL '1 hour'),
 
('88888888-8888-8888-8888-888888888889', '77777777-7777-7777-7777-777777777777',
 'Clean Architecture, yazılım tasarımında endişelerin ayrılmasını sağlayan bir mimari desendir. Domain katmanı merkeze alınır ve framework bağımlılıkları tersine çevrilir.',
 FALSE, NOW() - INTERVAL '1 hour' + INTERVAL '5 seconds')
ON CONFLICT (id) DO NOTHING;

-- Seed Message Sources
INSERT INTO message_sources (message_id, document_id, chunk_id, excerpt, page_label) VALUES
('88888888-8888-8888-8888-888888888889', '55555555-5555-5555-5555-555555555555',
 '66666666-6666-6666-6666-666666666666',
 'Clean Architecture bağımlılıkları tersine çevirerek domain katmanını framework''den bağımsız tutar.',
 'Sayfa 12')
ON CONFLICT DO NOTHING;

-- Seed Inventory Items
INSERT INTO inventory_items (id, name, category, gold_cost, asset_path, description) VALUES
('99999999-9999-9999-9999-999999999991', 'Klasik Saksı', 'pot', 0, 'assets/items/pot_classic.png', 'Başlangıç saksısı'),
('99999999-9999-9999-9999-999999999992', 'Altın Saksı', 'pot', 500, 'assets/items/pot_gold.png', 'Prestijli altın saksı'),
('99999999-9999-9999-9999-999999999993', 'Orman Arkaplanı', 'background', 300, 'assets/items/bg_forest.png', 'Huzurlu orman manzarası'),
('99999999-9999-9999-9999-999999999994', 'Kedi Arkadaş', 'companion', 800, 'assets/items/companion_cat.png', 'Şirin kedi yoldaşı')
ON CONFLICT (id) DO NOTHING;

-- Seed User Inventory (user owns classic pot)
INSERT INTO user_inventory (user_id, item_id, is_equipped, purchased_at) VALUES
('11111111-1111-1111-1111-111111111111', '99999999-9999-9999-9999-999999999991', TRUE, NOW() - INTERVAL '30 days')
ON CONFLICT (user_id, item_id) DO NOTHING;
