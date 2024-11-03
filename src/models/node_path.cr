class NodePath < Granite::Base
  connection pg
  table node_paths

  belongs_to :parent_node_path, class_name: NodePath, optional: true
  belongs_to :disk
  belongs_to :tag, optional: true
  belongs_to :move_tag, class_name: Tag, optional: true

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

    df_count = node_files.count.to_s.to_i64
    df_sum = node_files.map { |nf| nf.materialized_duplication_count.not_nil! }.sum

    return if df_count == 0

    self.materialized_duplication_factor = (df_sum.to_f * 100.0 / df_count.to_f).round.to_i
    self.save!
  end

  def self_and_subdirectories
    node_paths = Array(NodePath).new
    node_paths << self

    children_node_paths.each do |path|
      node_paths += path.self_and_subdirectories
    end

    return node_paths.uniq
  end
end
