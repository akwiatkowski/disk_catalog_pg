require "./storage"
require "./db_cache/cache"

class Scanner::CacheToDb::Processor
  def initialize(@disk : Disk)
    @db_cache = DbCache::Cache.new(
      disk: @disk
    )
    @full_cache = FullCache::Scanner.new(
      disk: @disk
    )
    @removed_cache = RemovedCache::Scanner.new(
      disk: @disk
    )
    @storage = Scanner::CacheToDb::Storage.new(
      disk: @disk,
      db_cache: @db_cache
    )

    @total_files_checked = 0
  end

  def make_it_so
    cache_units = load_full_cache
    node_files = load_node_files

    file_paths = (cache_units.keys + node_files.keys).uniq.sort

    puts "disk #{@disk.name} - total #{file_paths.size} file paths/keys to process"

    file_paths.each_with_index do |file_path, i|
      cache_unit = cache_units[file_path]?
      node_file = node_files[file_path]?

      @storage.persist(
        cache_unit: cache_unit,
        node_file: node_file,
        file_path: file_path,
      )
    end
  end

  def load_full_cache
    @full_cache.load
    return @full_cache.cache.files
  end

  def load_node_files
    node_files = Hash(String, NodeFile).new
    @disk.node_files.each do |node_file|
      next if node_file.file_path.nil?
      node_files[node_file.file_path.not_nil!] = node_file
    end

    return node_files
  end
end
