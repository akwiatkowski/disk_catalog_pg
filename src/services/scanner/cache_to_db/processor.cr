class Scanner::CacheToDb::Processor
  def initialize(@disk : Disk)
    @full_cache = FullCache::Scanner.new(
      disk: @disk
    )
    @removed_cache = RemovedCache::Scanner.new(
      disk: @disk
    )

    @total_files_checked = 0
  end

  def make_it_so
    load_full_cache
    node_files = load_node_files
    node_files.each_key do |path|
      cache_unit = @full_cache[path]?
      node_file = node_files[path]?
    end
  end

  def load_full_cache
    @full_cache.load
  end

  def load_node_files
    node_files = Hash(String, NodeFile).new
    @disk.node_files.each do |node_file|
      next if node_file.file_path.nil?
      node_files[node_file.file_path.not_nil!] = node_file
    end

    return node_files
  end

  def compare(cache_unit : FullCache::Unit, node_file : NodeFile)
    if node_file.nil? && !cache_unit.nil?
      create(cache_unit: cache_unit)
    elsif !node_file.nil? && !cache_unit.nil?
      update(cache_unit: cache_unit, node_file: node_file)
    elsif !node_file.nil? && cache_unit.nil?
      delete(node_file: node_file)
    else
      raise NotImplemented
    end
  end

  def create(cache_unit : FullCache::Unit)
  end

  def update(cache_unit : FullCache::Unit, node_file : NodeFile)
  end

  def delete(node_file : NodeFile)
  end

  # def run
  #   puts @full_cache.cache.inspect
  #   .each do |node_file|
  #     @total_files_checked += 1
  #
  #     puts @full_cache[node_file.file_path.to_s]?.inspect
  #
  #     # update
  #     # if @full_cache[node_file.file_path.to_s]?
  #     #   puts node_file
  #     # else
  #     #   puts node_file
  #     # end
  #   end
  # end
end
