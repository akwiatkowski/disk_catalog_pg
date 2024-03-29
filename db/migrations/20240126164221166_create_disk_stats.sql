-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW disk_stats
AS
  select
    disks.*,
    coalesce(sum(meta_files.size), 0)::bigint as total_disk_size,
    count(node_files.id)::bigint as total_files_count
  from disks
  left join node_files on node_files.disk_id = disks.id
  left join meta_files on meta_files.id = node_files.meta_file_id
  -- some weird error with special files
  where coalesce(meta_files.size, 1) < 100000000000
  group by disks.id
  order by disks.name
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS disk_stats ;
