class NodeFile < Granite::Base
  connection pg
  table node_files

  belongs_to :meta_file
  belongs_to :disk
  belongs_to :node_path, optional: true

  column id : Int64, primary: true
  # TODO: add basename
  column file_path : String?
  timestamps
end
