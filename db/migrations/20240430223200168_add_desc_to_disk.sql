-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE disks
ADD COLUMN description TEXT;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE disks
DROP COLUMN description;
