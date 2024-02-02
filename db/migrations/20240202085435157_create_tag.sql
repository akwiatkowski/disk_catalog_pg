-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE tags (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR,
  description VARCHAR,
  materialized_total_size BIGINT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(name)
);
CREATE INDEX tags_name_idx ON tags (name);

-- +micrate Down
DROP TABLE IF EXISTS tags;
