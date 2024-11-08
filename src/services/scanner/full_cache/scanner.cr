require "./container"
require "./unit"

# similar to HashCache but it perform all operation and store
# hash locally. So you can run disk related operation w/o having
# disk connected. WIP
class Scanner::FullCache::Scanner
  FORCE_SAVE_AFTER        =  400
  LOG_EVERY_WHEN_NEW_FILE =   20
  LOG_EVERY_EVERY_FILE    = 1000
  DEBUG_PUTS              = false

  def initialize(@disk : Disk)
    @disk_path = Path.new(disk.path.not_nil!)
    @local_path = "/home/olek/.disk_catalog/full_cache/"
    Dir.mkdir_p(path: @local_path)
    @cache_path = "#{@local_path}/#{disk.slug}.yml"

    @disk_scanner = ::Scanner::DiskScanner.new(path: @disk_path)
    @cache = Container.new(@disk)

    @was_loaded = false
    @new_files_count = 0
    @total_size = 0.to_i64
    @processed_files_count = 0
    @updated_files_count = 0
  end

  getter :cache

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

    puts "save cache_path=#{@cache_path}"
    File.open(@cache_path, "w") do |f|
      @cache.to_yaml(f)
    end
    puts "save completed"
  end

  def reset
    @cache = Container.new(@disk)
  end

  def make_it_so
    @disk_scanner.make_it_so
    @disk_scanner.file_paths.each do |file_path|
      if self[file_path]?.nil?
        begin
          unit = Unit.new(file_path: file_path)
          @total_size += unit.size
          @processed_files_count += 1
          self[file_path] = unit
        rescue File::NotFoundError
          # TODO: add logging
        end
      else
        begin
          # unit = self[file_path]?.as(Unit)
          unit = @cache.files[file_path.to_s]
          update_result = unit.update!(file_path: file_path)
          if update_result
            # only change cache if there was change
            # to not overwrite cache too often
            self[file_path] = unit
            @updated_files_count += 1
          end
          @total_size += unit.size
          @processed_files_count += 1
        rescue File::NotFoundError
          # TODO: add logging
        end
      end

      log(file_path) if should_log?
    end

    @cache.reset_last_cache_time!
    save
  end

  def should_log?
    return (@new_files_count % LOG_EVERY_WHEN_NEW_FILE == (LOG_EVERY_WHEN_NEW_FILE - 1)) ||
      (@processed_files_count % LOG_EVERY_EVERY_FILE == (LOG_EVERY_EVERY_FILE - 1))
  end

  def should_save?
    return @new_files_count > FORCE_SAVE_AFTER
  end

  def files_to_force_save
    FORCE_SAVE_AFTER - @new_files_count
  end

  def log(file_path)
    puts "#{file_path}: new_files=#{@new_files_count}, all_files=#{@processed_files_count}, files_to_force_save=#{files_to_force_save}, cached=#{@cache.files.keys.size}, total_size=#{SizeTools.to_human(@total_size)}, updated=#{@updated_files_count}"
  end

  def []?(file_path)
    load unless @was_loaded
    return @cache.files[file_path.to_s]?
  end

  def []=(file_path, cache_unit)
    @new_files_count += 1
    if should_save?
      save
      @new_files_count = 0
    end

    @cache.files[file_path.to_s] = cache_unit
  end
end
