class JoinedFile < Granite::Base
  connection pg
  table joined_files

  belongs_to :meta_file
  belongs_to :disk
  belongs_to :node_path, optional: true

  column id : Int64, primary: true
  column file_path : String?
  column basename : String?
  column node_path_basename : String?
  column file_extension : String?
  column hash : String?
  column size : Int64?
  column modification_time : Time?
  column disk_name : String?
  column mime_type : String?
  timestamps

  def duplications
    return meta_file.joined_files.select { |other_node| other_node.id != self.id }
  end
end
