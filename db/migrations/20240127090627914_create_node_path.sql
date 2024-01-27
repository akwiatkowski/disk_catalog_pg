-- +micrate Up
CREATE TABLE node_paths (
  id BIGSERIAL PRIMARY KEY,
  disk_id BIGINT,
  parent_path_node_id BIGINT,
  relative_path VARCHAR,
  basename VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(disk_id, relative_path)
);
CREATE INDEX node_path_disk_id_idx ON node_paths (disk_id);
CREATE INDEX node_path_parent_path_node_id_idx ON node_paths (parent_path_node_id);

-- +micrate Down
DROP TABLE IF EXISTS node_paths;
