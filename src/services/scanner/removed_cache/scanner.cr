require "./container"

# just store info of files which are missing in disk
class Scanner::RemovedCache::Scanner
  FORCE_SAVE_AFTER = 2000
  DEBUG_PUTS       = true

  def initialize(@disk : Disk)
    @disk_path = Path.new(disk.path.not_nil!)
    @local_path = "/home/olek/.disk_catalog/removed_cache/"
    Dir.mkdir_p(path: @local_path)
    @cache_path = "#{@local_path}/#{disk.slug}.yml"

    @disk_scanner = ::Scanner::DiskScanner.new(path: @disk_path)
    @cache = Container.new(@disk)

    @was_loaded = false
    @counter_for_save = 0
    @total_files_checked = 0
  end

  def load
    puts "load cache_path=#{@cache_path}" if DEBUG_PUTS
    if File.exists?(@cache_path)
      @cache = Container.from_yaml(File.open(@cache_path))
    end
    @was_loaded = true
  end

  def save
    # just for backup
    File.rename(
      old_filename: @cache_path,
      new_filename: "#{@cache_path}.bak"
    ) if File.exists?(@cache_path)

    puts "save @cache_path=#{@cache_path}, @total_files_checked=#{@total_files_checked}" if DEBUG_PUTS
    File.open(@cache_path, "w") do |f|
      @cache.to_yaml(f)
    end
  end

  def reset
    @cache = Container.new(@disk)
  end

  def make_it_so
    @disk.node_files.each do |node_file|
      @total_files_checked += 1

      next if File.exists?(node_file.file_path.to_s)
      next if @cache.file_paths.includes?(node_file.file_path.to_s)

      @cache.file_paths << node_file.file_path.to_s

      if @counter_for_save > FORCE_SAVE_AFTER
        puts "saving #{@cache.file_paths.size}"
        @counter_for_save = 0
      end
    end

    @cache.reset_last_cache_time!(total_files_checked: @total_files_checked)
    save
  end
end
