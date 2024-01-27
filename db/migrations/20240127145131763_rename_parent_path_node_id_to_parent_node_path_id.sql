-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_paths
RENAME COLUMN parent_path_node_id TO parent_node_path_id;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_paths
RENAME COLUMN parent_node_path_id TO parent_path_node_id;
