-- +micrate Up
CREATE TABLE meta_files (
  id BIGSERIAL PRIMARY KEY,
  hash VARCHAR,
  size BIGINT,
  modification_time TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(hash, size)
);
CREATE INDEX meta_files_scanner_idx ON meta_files (hash, size);

-- +micrate Down
DROP TABLE IF EXISTS meta_files;
