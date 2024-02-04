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
  column materialized_duplication_factor : Int32?
  timestamps

  def update_duplication_factor!
    node_files = NodeFile.where(node_path_id: id).where("materialized_duplication_count is not null")

    df_count = node_files.count
    df_sum = node_files.map { |nf| nf.materialized_duplication_factor }.sum

    return if df_count == 0

    self.materialized_duplication_factor = (df_count.to_f * 100.0 / df_sum.to_f).round.to_i
    self.save!
  end
end
