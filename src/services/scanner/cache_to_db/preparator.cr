# prepare required instances before create NodeFile
class Scanner::CacheToDb::Preparator
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

  getter :mime_type, :meta_file, :disk, :file_path, :node_path

  def basename
    return Path.new(@file_path.to_s).basename
  end

  def file_extension
    return Path.new(@file_path).extension.gsub(/^\./, "").to_s.downcase
  end
end
