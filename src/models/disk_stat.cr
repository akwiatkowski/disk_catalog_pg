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

  def total_disk_size_human
    size_gbs = (total_disk_size || 0.0).to_f / (1024.0 ** 3)
    return (size_gbs * 100.0).round / 100.0
  end
end
