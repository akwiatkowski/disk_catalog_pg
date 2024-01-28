require "../services/size_tools"

class MetaFile < Granite::Base
  connection pg
  table meta_files

  has_many node_files : NodeFile

  column id : Int64, primary: true
  column hash : String?
  column size : Int64?
  column modification_time : Time?

  # TODO: add mime, photo taken at time in external table
  # TODO: add helper method to calculate size in human readable form

  timestamps

  def size_human
    SizeTools.to_human(size)
  end
end
