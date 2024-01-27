-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW duplicated_hash_stats
AS
  select
    meta_files.hash,
    count(meta_files.id) as duplications
  from meta_files
  where
    meta_files.size > 100000 and
    meta_files.hash != ''
  group by
    meta_files.hash
  having count(meta_files.id) > 1
  order by duplications desc;
;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW IF EXISTS duplicated_hash_stats ;
