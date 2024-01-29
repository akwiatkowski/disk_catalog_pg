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
  timestamps

  def basename
    return Path.new(file_path.to_s).basename
  end

  def duplications
    return meta_file.node_files.select { |other_node| other_node.id != self.id }
  end
end
