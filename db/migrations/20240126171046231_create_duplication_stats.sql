-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW duplication_stats
AS
  select
    node_files.meta_file_id,
    count(node_files.id) as duplications,
    substring(node_files.file_path from '[^/]+$') as file_name,
    meta_files.size as file_size
  from node_files
  join meta_files on meta_files.id = node_files.meta_file_id
  where meta_files.size > 1000000
  group by
    node_files.meta_file_id,
    file_name,
    file_size
  having count(node_files.id) > 2
  order by duplications desc;
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS duplication_stats ;
