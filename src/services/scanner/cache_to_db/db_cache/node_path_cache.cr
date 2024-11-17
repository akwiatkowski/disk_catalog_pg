class Scanner::CacheToDb::DbCache::NodePathCache
  def initialize(@disk : Disk)
    @cache = Hash(String, NodePath).new
    @disk_path_sanitized = @disk.path.to_s.gsub(/\/$/, "")
  end

  def instance_for(file_path)
    relative_file_path = Path.new(
      file_path.to_s.gsub(@disk_path_sanitized, "/").gsub(/\/{2,10}/, "/")
    )

    # puts "-- #{file_path.to_s} . #{@disk_path_sanitized} -> #{relative_file_path}"

    if @cache[relative_file_path.to_s]?.nil?
      # create parent directories
      parent_node_path = nil
      relative_file_path.each_parent do |directory_path|
        if @cache[directory_path]?.nil?
          node_path = find_or_create_node_path_for_parent_path(
            directory_path: directory_path,
            parent_node_path: parent_node_path
          )
          @cache[directory_path.to_s] = node_path.not_nil!
        end
        parent_node_path = node_path
      end

      # create missing one
      node_path = find_or_create_node_path_for_parent_path(
        directory_path: relative_file_path.to_s,
        parent_node_path: parent_node_path
      )
      @cache[relative_file_path.to_s] = node_path.not_nil!
    end

    # puts "++ #{@cache[relative_file_path.to_s].inspect}"
    return @cache[relative_file_path.to_s]
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
