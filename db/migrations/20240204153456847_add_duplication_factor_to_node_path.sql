-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE node_paths
ADD COLUMN materialized_duplication_factor INTEGER;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE node_paths
DROP COLUMN materialized_duplication_factor;
