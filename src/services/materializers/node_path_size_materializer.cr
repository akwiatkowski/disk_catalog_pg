class Materializers::NodePathSizeMaterializer
  def initialize(@disk : Disk)
  end

  def make_it_so
    main_node_path = NodePath.find_by(
      disk_id: @disk.id,
      parent_node_path_id: nil
    ).not_nil!
    calcuate_size_for_node_path(main_node_path)
  end

  # TODO: optimize n+1 or better - create postgres function
  def calcuate_size_for_node_path(node_path : NodePath)
    size = 0.to_i64
    node_path.children_node_paths.each do |children_node_path|
      children_node_path_size = calcuate_size_for_node_path(
        node_path: children_node_path
      )
      size += children_node_path_size
    end

    files_size = 0.to_i64
    node_path.node_files.each do |node_file|
      files_size += node_file.meta_file.size.not_nil!.to_i64
    end
    size += files_size

    # TODO: separate calculations from modification of DB
    node_path.size = size
    node_path.save!

    return size
  end
end
