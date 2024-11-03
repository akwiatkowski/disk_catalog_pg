require "./container"
require "./unit"

# similar to HashCache but it perform all operation and store
# hash locally. So you can run disk related operation w/o having
# disk connected. WIP
class Scanner::FullCache::Scanner
  FORCE_SAVE_AFTER = 500
  DEBUG_PUTS       = false

  def initialize(@disk : Disk)
    @disk_path = Path.new(disk.path.not_nil!)
    @local_path = "/home/olek/.disk_catalog/full_cache/"
    Dir.mkdir_p(path: @local_path)
    @cache_path = "#{@local_path}/#{disk.slug}.yml"

    @disk_scanner = ::Scanner::DiskScanner.new(path: @disk_path)
    @cache = Container.new(@disk)

    @was_loaded = false
    @counter_for_save = 0
  end

  def load
    puts "load cache_path=#{@cache_path}" if DEBUG_PUTS
    if File.exists?(@cache_path)
      @cache = Container.from_yaml(File.open(@cache_path))
    end
    @was_loaded = true
  end

  def save
    puts "save cache_path=#{@cache_path}" if DEBUG_PUTS
    File.open(@cache_path, "w") do |f|
      @cache.to_yaml(f)
    end
  end

  def reset
    @cache = Container.new(@disk)
  end

  def make_it_so
    @disk_scanner.make_it_so
    @disk_scanner.file_paths.each do |file_path|
      if self[file_path]?.nil?
        self[file_path] = Unit.new(file_path: file_path)
      end
    end

    @cache.reset_last_cache_time!
    save
  end

  def []?(file_path)
    puts "get #{file_path}, i=#{@counter_for_save}, keys=#{@cache.files.keys.size}" if DEBUG_PUTS

    load unless @was_loaded
    return @cache.files[file_path.to_s]?
  end

  def []=(file_path, cache_unit)
    puts "set #{file_path}, i=#{@counter_for_save}, keys=#{@cache.files.keys.size}" if DEBUG_PUTS

    @counter_for_save += 1
    if @counter_for_save > FORCE_SAVE_AFTER
      save
      @counter_for_save = 0
    end

    @cache.files[file_path.to_s] = cache_unit
  end
end
