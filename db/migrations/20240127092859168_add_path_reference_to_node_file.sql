-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_files
ADD COLUMN node_path_id BIGINT;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_files
DROP COLUMN node_path_id;
