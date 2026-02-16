-- migrate:up

ALTER TABLE documents
ADD COLUMN content_text TEXT;

-- migrate:down

ALTER TABLE documents
DROP COLUMN content_text;
