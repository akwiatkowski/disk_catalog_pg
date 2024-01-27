-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE INDEX node_file_to_node_path_idx ON node_files (node_path_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX node_file_to_node_path_idx;
