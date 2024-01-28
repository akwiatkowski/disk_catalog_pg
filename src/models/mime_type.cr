class MimeType < Granite::Base
  connection pg
  table mime_types

  has_many meta_files : MetaFile

  column id : Int64, primary: true
  column name : String?
  timestamps
end
