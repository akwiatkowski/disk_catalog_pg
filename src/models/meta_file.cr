require "../services/size_tools"

class MetaFile < Granite::Base
  connection pg
  table meta_files

  has_many node_files : NodeFile
  has_many joined_files : JoinedFile # , foreign_key: :node_file_id
  belongs_to :mime_type, optional: true

  column id : Int64, primary: true
  column hash : String?
  column size : Int64?
  column modification_time : Time?

  # TODO: add photo taken at time in external table

  timestamps

  def size_human
    SizeTools.to_human(size)
  end
end
