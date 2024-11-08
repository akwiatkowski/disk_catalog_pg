class Scanner::CacheToDb::Create
  def initialize(
    @cache_unit : FullCache::Unit,
    @disk : Disk,
    @file_path : String
  )
    @mime_type = find_or_initialize_mime_type.as(MimeType)
    @meta_file = find_or_create_meta_file.as(MetaFile)
    @node_path = find_or_create_node_path.as(NodePath)
  end

  getter :mime_type, :meta_file, :disk, :file_path

  def run
  end

  # TODO: move to module
  def hash
    return @cache_unit.hash
  end

  def size
    return @cache_unit.size
  end

  def modification_time
    return @cache_unit.modification_time
  end

  def mime_type_string
    return @cache_unit.mime_type
  end

  def basename
    return Path.new(@file_path).basename
  end

  def file_extension
    return @file_entity.file_extension
  end

  def create_node_file
    NodeFile.create(
      meta_file: meta_file,
      disk: disk,
      node_path: node_path,

      file_path: file_path,
      basename: basename,
      file_extension: file_extension
    )
  end

  def find_or_create_meta_file
    if MetaFile.where(hash: hash, size: size).exists?
      return MetaFile.find_by(hash: hash, size: size)
    else
      return MetaFile.create(
        hash: hash,
        size: size,
        modification_time: modification_time,
        mime_type: mime_type
      )
    end
  end

  def find_or_create_node_path
    disk_path = Path.new(@disk.path.not_nil!)
    relative_file_path = Path.new(@file_path.gsub(@disk.path.not_nil!, "/"))

    parent_node_path = nil

    relative_file_path.each_parent do |directory_path|
      parent_node_path = find_or_create_node_path_for_parent_path(
        directory_path: directory_path,
        parent_node_path: parent_node_path
      )
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
        relative_path: directory_path,
        basename: Path.new(directory_path).basename,
        parent_node_path_id: parent_node_path_id
      )
    end
  end

  def find_or_initialize_mime_type
    if MimeType.where(name: mime_type_string).exists?
      return MimeType.find_by(name: mime_type_string)
    else
      return MimeType.create(name: mime_type_string)
    end
  end
end
