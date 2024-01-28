-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE meta_files
ADD COLUMN mime_type_id BIGINT;

CREATE INDEX meta_files_mime_type_idx ON meta_files (mime_type_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE meta_files
DROP COLUMN mime_type_id;
