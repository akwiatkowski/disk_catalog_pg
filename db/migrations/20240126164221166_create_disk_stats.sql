-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW disk_stats
AS
  select
    disks.*,
    sum(meta_files.size) as total_disk_size,
    count(node_files.id) as total_files_count
  from disks
  join node_files on node_files.disk_id = disks.id
  join meta_files on meta_files.id = node_files.meta_file_id
  -- some weird error with special files
  where meta_files.size < 100000000000
  group by disks.id
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS disk_stats ;
