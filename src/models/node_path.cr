class NodePath < Granite::Base
  connection pg
  table node_paths

  belongs_to :parent_path_node, optional: true
  belongs_to :disk

  has_many :node_files

  column id : Int64, primary: true
  column relative_path : String?
  column basename : String?
  timestamps
end
