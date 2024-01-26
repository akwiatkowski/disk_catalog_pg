-- +micrate Up
CREATE TABLE disks (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR,
  path VARCHAR,
  size INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(name)
);


-- +micrate Down
DROP TABLE IF EXISTS disks;
