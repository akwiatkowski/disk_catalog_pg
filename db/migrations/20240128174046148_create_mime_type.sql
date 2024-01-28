-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE mime_types (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(name)
);
CREATE INDEX mime_types_name_idx ON mime_types (name);

-- +micrate Down
DROP TABLE IF EXISTS mime_types;
