class Scanner::CacheToDb::Create
  def initialize(
    @cache_unit : FullCache::Unit,
    @disk : Disk,
    @file_path : String,
    @db_cache : DbCache::Cache
  )
    @mime_type = @db_cache.mime_type_cache.instance_for(
      mime_type_string: @cache_unit.mime_type
    ).as(MimeType)

    @meta_file = @db_cache.meta_file_cache.instance_for(
      hash: @cache_unit.hash,
      size: @cache_unit.size,
      modification_time: @cache_unit.modification_time,
      mime_type: @mime_type
    ).as(MetaFile)

    @node_path = @db_cache.node_path_cache.instance_for(
      Path.new(@file_path).parent
    ).as(NodePath)
  end

  getter :mime_type, :meta_file, :disk, :file_path

  def run
    find_or_create_node_file
  end

  def basename
    return Path.new(@file_path).basename
  end

  # def file_extension
  #   return @file_entity.file_extension
  # end
  def file_extension
    return Path.new(@file_path).extension.gsub(/^\./, "").to_s.downcase
  end

  def find_or_create_node_file
    if NodeFile.where(
         meta_file_id: @meta_file.id.not_nil!,
         disk_id: @disk.id.not_nil!,
         node_path_id: @node_path.id.not_nil!,
         file_path: @file_path.to_s
       ).exists?
      return NodeFile.find_by(
        meta_file_id: @meta_file.id.not_nil!,
        disk_id: @disk.id.not_nil!,
        node_path_id: @node_path.id.not_nil!,
        file_path: @file_path.to_s
      )
    else
      return NodeFile.create(
        meta_file_id: @meta_file.id.not_nil!,
        disk_id: @disk.id.not_nil!,
        node_path_id: @node_path.id.not_nil!,
        file_path: @file_path.to_s,
        basename: Path.new(@file_path.to_s).basename,
        file_extension: file_extension
      )
    end
  end
end
