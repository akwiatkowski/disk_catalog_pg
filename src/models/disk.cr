class Disk < Granite::Base
  connection pg
  table disks

  has_many node_paths : NodePath
  has_many node_files : NodeFile

  column id : Int64, primary: true
  column name : String?
  column path : String?
  column size : Int32?
  timestamps

  def main_node_path
    return NodePath.find_by(disk_id: self.id, parent_node_path_id: nil)
  end

  def indexed_size
    mnp = main_node_path
    if mnp
      return mnp.not_nil!.size
    else
      return nil
    end
  end
end
