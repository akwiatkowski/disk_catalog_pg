-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW joined_files
AS
  select
    node_files.*,
    meta_files.hash,
    meta_files.size,
    meta_files.modification_time,
    disks.name as disk_name,
    mime_types.name as mime_type
  from node_files
  join meta_files on meta_files.id = node_files.meta_file_id
  join disks on disks.id = node_files.disk_id
  join mime_types on meta_files.mime_type_id = mime_types.id
  -- some weird error with special files
  where meta_files.size < 100000000000
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS joined_files ;
