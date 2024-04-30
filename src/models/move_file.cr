class MoveFile < Granite::Base
  connection pg
  table move_files

  belongs_to :node_path
  belongs_to :meta_file
  belongs_to :tag
  belongs_to :disk
  belongs_to :node_file

  column node_file_id : Int64, primary: true
  column relative_path : String
  column path_basename : String
  column file_size : Int64
  column tag_name : String
  column disk_name : String
  column file_path : String
  column file_basename : String

  def move_relative_path
    Path.new(
      parts: Path.new(self.relative_path).parts[1..-1]
    )
  end

  def parity_file
    return file_path.includes?(".par2")
  end

  def should_be_ignored
    return parity_file
  end
end
