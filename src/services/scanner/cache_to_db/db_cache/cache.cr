require "./mime_type_cache"

class Scanner::CacheToDb::DbCache::Cache
  def initialize(@disk : Disk)
    @mime_type_cache = MimeTypeCache.new(disk: @disk)
  end

  getter :mime_type_cache
end
