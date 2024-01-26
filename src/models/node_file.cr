class NodeFile < Granite::Base
  connection pg
  table node_files

  belongs_to :meta_file

  belongs_to :disk

  column id : Int64, primary: true
  column file_path : String?
  timestamps
end
