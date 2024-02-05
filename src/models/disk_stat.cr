require "../services/size_tools"

class DiskStat < Granite::Base
  connection pg
  table disk_stats

  has_many :node_paths

  column id : Int64, primary: true
  column name : String?
  column path : String?
  column size : Int32?
  column total_disk_size : Int64?
  column total_files_count : Int64?
  timestamps
end
