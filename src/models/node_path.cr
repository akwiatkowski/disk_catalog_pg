class NodePath < Granite::Base
  connection pg
  table node_paths

  belongs_to :parent_node_path, class_name: NodePath, optional: true
  belongs_to :disk
  belongs_to :tag, optional: true

  has_many :node_files
  has_many :children_node_paths, class_name: NodePath, foreign_key: :parent_node_path_id

  column id : Int64, primary: true
  column relative_path : String?
  column basename : String?
  column size : Int64?
  timestamps
end
