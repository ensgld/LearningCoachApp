-- migrate:up

ALTER TABLE documents
ADD COLUMN processing_progress NUMERIC(5, 2) NOT NULL DEFAULT 0.00;

-- migrate:down

ALTER TABLE documents
DROP COLUMN IF EXISTS processing_progress;
