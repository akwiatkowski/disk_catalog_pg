-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_paths
ADD COLUMN tag_id BIGINT;

CREATE INDEX node_paths_tag_idx ON node_paths (tag_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_paths
DROP COLUMN tag_id;
