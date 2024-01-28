class Disk < Granite::Base
  connection pg
  table disks

  has_many node_paths : NodePath

  column id : Int64, primary: true
  column name : String?
  column path : String?
  column size : Int32?
  timestamps
end
