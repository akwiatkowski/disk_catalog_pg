class NodeFile < Granite::Base
  connection pg
  table node_files

  belongs_to :meta_file
  belongs_to :disk
  belongs_to :node_path, optional: true

  column id : Int64, primary: true
  column file_path : String?
  column basename : String?
  column file_extension : String?
  column materialized_duplication_count : Int32?
  timestamps

  def parent_path
    return Path.new(file_path.to_s).parent
  end

  def duplications
    return meta_file.node_files.select { |other_node| other_node.id != self.id }
  end
end
