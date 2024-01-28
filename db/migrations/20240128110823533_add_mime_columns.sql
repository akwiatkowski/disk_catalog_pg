-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_files
ADD COLUMN basename VARCHAR;

ALTER TABLE node_files
ADD COLUMN file_extension VARCHAR;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_files
DROP COLUMN basename, file_extension;
