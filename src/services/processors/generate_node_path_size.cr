require "../size_tools"

class Processors::GenerateNodePathSize
  def initialize
  end

  def recalculate_disk(disk : Disk, overwrite = false)
    node_paths = NodePath.where(disk_id: disk.id)
    if overwrite = false
      note_paths = node_paths.where(size: nil)
    end
    count = node_paths.count

    puts "#{count} need to recalculate size"
    node_paths.each do |node_path|
      recalculate_node_path_size(node_path)
    end
  end

  def recalculate_node_path_size(node_path : NodePath) : Int64
    child_node_paths = NodePath.where(parent_node_path_id: node_path.id)
    puts "#{node_path.relative_path} processing with #{child_node_paths.count} children"

    children_size = 0_i64
    child_node_paths.each do |child_node_path|
      children_size += recalculate_node_path_size(child_node_path)
    end

    files_size = JoinedFile.where(node_path_id: node_path.id).map do |file_joined|
      (file_joined.size || 0_i64).as(Int64)
    end.sum

    total_size = files_size + children_size

    node_path.size = total_size
    node_path.save

    puts "#{node_path.relative_path} has #{SizeTools.to_human(children_size)} children size, #{SizeTools.to_human(files_size)} files size, #{SizeTools.to_human(total_size)}"

    return total_size
  end
end
