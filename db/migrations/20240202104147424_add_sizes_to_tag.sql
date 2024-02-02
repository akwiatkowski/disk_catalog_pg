-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE tags
ADD COLUMN materialized_uniq_size BIGINT;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE tags
DROP COLUMN materialized_uniq_size;
