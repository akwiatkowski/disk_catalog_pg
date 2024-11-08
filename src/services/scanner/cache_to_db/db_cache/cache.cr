require "./mime_type_cache"
require "./meta_file_cache"
require "./node_path_cache"

class Scanner::CacheToDb::DbCache::Cache
  def initialize(@disk : Disk)
    @mime_type_cache = MimeTypeCache.new(disk: @disk)
    @meta_file_cache = MetaFileCache.new(disk: @disk)
    @node_path_cache = NodePathCache.new(disk: @disk)
  end

  getter :mime_type_cache, :meta_file_cache, :node_path_cache
end
