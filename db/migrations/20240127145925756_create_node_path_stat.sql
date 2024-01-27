-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

-- TODO: not working
CREATE OR REPLACE VIEW node_path_stats
AS
  select
    node_path_stats.*,
    sum(meta_files.size)::bigint as total_disk_size,
    count(node_files.id)::bigint as total_files_count
  from node_paths
  join node_files on node_files.node_path_id = node_paths.id
  join meta_files on meta_files.id = node_files.meta_file_id
  -- some weird error with special files
  where meta_files.size < 100000000000
  group by disks.id
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS node_path_stats ;
