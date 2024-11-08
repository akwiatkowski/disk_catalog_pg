class Scanner::CacheToDb::DbCache::NodePathCache
  def initialize(@disk : Disk)
    @cache = Hash(String, NodePath).new
    # @disk_path = Path.new(@disk.path.not_nil!)
  end

  def instance_for(file_path)
    relative_file_path = Path.new(file_path.gsub(@disk.path.not_nil!, "/"))

    if @cache[relative_file_path.to_s]?.nil?
      @cache[relative_file_path.to_s] = find_or_create_for(relative_file_path).not_nil!
    end

    return @cache[relative_file_path]
  end

  def find_or_create_for(relative_file_path)
    parent_node_path = nil

    relative_file_path.each_parent do |directory_path|
      node_path = find_or_create_node_path_for_parent_path(
        directory_path: directory_path,
        parent_node_path: parent_node_path
      )
      @cache[directory_path.to_s] = node_path.not_nil!

      parent_node_path = node_path
    end

    return parent_node_path.not_nil!
  end

  def find_or_create_node_path_for_parent_path(
    directory_path : String | Path,
    parent_node_path : NodePath?
  )
    if NodePath.where(
         disk_id: @disk.id.not_nil!,
         relative_path: directory_path.to_s
       ).exists?
      return NodePath.find_by(
        disk_id: @disk.id.not_nil!,
        relative_path: directory_path.to_s
      )
    else
      parent_node_path_id = nil
      parent_node_path_id = parent_node_path.id if parent_node_path

      return NodePath.create(
        disk_id: @disk.id,
        relative_path: directory_path.to_s,
        basename: Path.new(directory_path).basename,
        parent_node_path_id: parent_node_path_id
      )
    end
  end
end
