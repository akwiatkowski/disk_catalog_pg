-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_paths
ADD COLUMN move_tag_id BIGINT;

CREATE INDEX node_paths_move_tag_idx ON node_paths (move_tag_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_paths
DROP COLUMN move_tag_id;
