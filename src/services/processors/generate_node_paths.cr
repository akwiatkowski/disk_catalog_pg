class GenerateNodePaths
  def initialize(@debug = false)
  end

  def all_overwrite
    process_nfs(nfs_overwrite)
  end

  def all_missing
    process_nfs(nfs_missing)
  end

  def nfs_overwrite
    return NodeFile.all
  end

  def nfs_missing
    return NodeFile.where(node_path_id: nil)
  end

  def process_nfs(nfs)
    i = 0_i64
    duplications = 0_i64
    count = nfs.size

    nfs.each do |node_file|
      puts "start" if i == 0

      populate_for_node_file(node_file)

      i += 1
      if (i % 1000) == 0
        puts "#{i}/#{count} NF generated paths (NodePath)"
      end
    end
  end

  def populate_for_node_file(node_file : NodeFile)
    return if node_file.file_path.nil?
    return if node_file.disk.path.nil?

    file_path_string = node_file.file_path.to_s
    disk = node_file.disk
    disk_path_string = disk.path.to_s

    full_file_path = Path.new(file_path_string)
    disk_path = Path.new(disk_path_string)
    relative_file_path = Path.new(file_path_string.gsub(disk_path_string, "/"))

    # puts "full_file_path = #{full_file_path}"
    # puts "disk_path = #{disk_path}"
    # puts "relative_file_path = #{relative_file_path}"

    parent_path_instance = nil : NodePath?
    relative_file_path.each_parent do |parent_directory|
      parent_path_instance = create_instance(
        disk: disk,
        node_file: node_file,
        parent_path_instance: parent_path_instance,
        parent_directory: parent_directory
      )
    end

    if parent_path_instance
      # assign file key to path
      node_file.node_path_id = parent_path_instance.not_nil!.id
      node_file.save

      puts "NF #{node_file.id} assign NP #{parent_path_instance.id} = #{parent_path_instance.relative_path}" if @debug
    end
  end

  def create_instance(
    disk,
    node_file,
    parent_path_instance,
    parent_directory
  )
    parent_node_path_id = nil
    parent_node_path_id = parent_path_instance.id if parent_path_instance

    relative_path = "/"
    relative_path = parent_directory if parent_directory

    basename = Path.new(relative_path).basename

    # find if exists
    node_path = NodePath.find_by(
      disk_id: disk.id.not_nil!,
      parent_node_path_id: parent_node_path_id,
      basename: basename.to_s
    )
    if node_path.nil?
      # if not create
      node_path = NodePath.create(
        disk_id: disk.id.not_nil!,
        parent_node_path_id: parent_node_path_id,
        basename: basename.to_s,
        relative_path: relative_path.to_s,
      )
      puts "created NP for parent id = #{parent_node_path_id}, basename = #{basename}, relative_path = #{relative_path}" if @debug
    end

    return node_path
  end
end
