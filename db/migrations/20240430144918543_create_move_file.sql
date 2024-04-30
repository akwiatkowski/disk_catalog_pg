-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW move_files
AS

  select
    node_paths.id as node_path_id,
    node_paths.relative_path as relative_path,
    node_paths.basename as path_basename,

    meta_files.id as meta_file_id,
    meta_files.size as file_size,

    tags.id as tag_id,
    tags.name as tag_name,

    disks.id as disk_id,
    disks.name as disk_name,

    node_files.id as node_file_id,
    node_files.file_path as file_path,
    node_files.basename as file_basename

  from node_files
  join node_paths on node_files.node_path_id = node_paths.id
  join tags on node_paths.move_tag_id = tags.id
  join meta_files on meta_files.id = node_files.meta_file_id
  join disks on disks.id = node_files.disk_id

  -- some weird error with special files
  where meta_files.size < 100000000000
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS move_files ;
