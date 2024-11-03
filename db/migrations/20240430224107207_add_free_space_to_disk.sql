-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE disks
ADD COLUMN free_space INT;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE disks
DROP COLUMN free_space;
