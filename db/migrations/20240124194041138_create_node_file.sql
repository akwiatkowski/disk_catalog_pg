-- +micrate Up
CREATE TABLE node_files (
  id BIGSERIAL PRIMARY KEY,
  meta_file_id BIGINT,
  disk_id BIGINT,
  file_path VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(meta_file_id, file_path)
);
CREATE INDEX node_file_scanner_idx ON node_files (meta_file_id, disk_id, file_path);

-- +micrate Down
DROP TABLE IF EXISTS node_files;
