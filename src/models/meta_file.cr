class MetaFile < Granite::Base
  connection pg
  table meta_files

  column id : Int64, primary: true
  column hash : String?
  column size : Int64?
  column modification_time : Time?
  timestamps
end
