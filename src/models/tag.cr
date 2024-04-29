class Tag < Granite::Base
  connection pg
  table tags

  column id : Int64, primary: true
  column name : String
  column description : String
  # total size how much it use disk space
  column materialized_total_size : Int64?
  # uniq files size, if there was no redundancy
  column materialized_uniq_size : Int64?

  timestamps

  has_many node_paths : NodePath
  has_many move_node_paths : NodePath, foreign_key: :move_tag_id

  def move_paths_count
    # puts "*"
    # puts NodePath.where(move_tag_id: self.id).count.to_s.inspect
    #
    # return 0
    return NodePath.where(move_tag_id: self.id).count.to_s.to_i
  end
end
