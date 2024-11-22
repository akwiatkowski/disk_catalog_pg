require "./container"
require "./unit"

# similar to HashCache but it perform all operation and store
# hash locally. So you can run disk related operation w/o having
# disk connected. WIP
class Scanner::FullCache::Scanner
  # TODO: convert from number of files to total size of files
  # because sometime there are big files (movies) or very small images or text
  FORCE_SAVE_AFTER_SIZE   = 2_000_000_000
  LOG_EVERY_WHEN_NEW_FILE =            50
  LOG_EVERY_EVERY_FILE    =          1000

  def initialize(@disk : Disk)
    @disk_path = Path.new(disk.path.not_nil!)
    @local_path = "/home/olek/.disk_catalog/full_cache/"
    Dir.mkdir_p(path: @local_path)
    @cache_path = "#{@local_path}/#{disk.slug}.yml"

    # for debug purpose it save scanned paths into temp cache
    # to be able to skip disk scan
    @scanned_cache_path = "#{@local_path}/#{disk.slug}.scan.yml"
    @file_paths = Array(String).new

    @disk_scanner = ::Scanner::DiskScanner.new(path: @disk_path)
    @cache = Container.new(@disk)

    @was_loaded = false
    @new_files_count = 0
    @total_size = 0.to_i64
    @processed_file_size = 0.to_i64
    @processed_files_count = 0
    @updated_files_count = 0
  end

  getter :cache

  def load
    if File.exists?(@cache_path)
      @cache = Container.from_yaml(File.open(@cache_path))
    end
    @was_loaded = true
  end

  def scan_disk_or_load_cache
    if File.exists?(@scanned_cache_path)
      puts "loading scan disk cache"
      @file_paths = Array(String).from_yaml(File.open(@scanned_cache_path))
      puts "load finished"
    else
      @disk_scanner.make_it_so
      @file_paths = @disk_scanner.file_paths

      puts "saving scan disk cache"
      save_disk_scan
      puts "save finished"
    end

    return @file_paths
  end

  def save_disk_scan
    File.open(@scanned_cache_path, "w") do |f|
      @file_paths.to_yaml(f)
    end
    puts "scanned disk cache save completed"
  end

  def remove_invalid_files
    @cache.files.each do |file_path, file_unit|
      unless file_unit.valid?
        puts "remove #{file_path} because is invalid"
        @cache.files.delete(file_path)
      end
    end
  end

  def save
    remove_invalid_files

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
    unless File.exists?(@disk_path)
      puts "path not mounted"
      return
    end

    scan_disk_or_load_cache
    insert_and_update
    delete

    @cache.reset_last_cache_time!
    save
  end

  def insert_and_update
    @file_paths.sort.each do |file_path|
      if self[file_path]?.nil?
        # file exists but it's not in full cache
        begin
          unit = Unit.new(file_path: file_path)
          # we don't need empty or very small files
          next unless unit.valid?

          @total_size += unit.size
          @processed_files_count += 1
          @processed_file_size += unit.size
          self[file_path] = unit
        rescue File::NotFoundError
          # TODO: add logging
        end
      else
        # file exists and it's in full cache
        begin
          unit = @cache.files[file_path.to_s]
          update_result = unit.update!(file_path: file_path)
          if update_result
            # only change cache if there was change
            # to not overwrite cache too often
            self[file_path.to_s] = unit
            @updated_files_count += 1
            @processed_file_size += unit.size
          end
          @total_size += unit.size
          @processed_files_count += 1
        rescue File::NotFoundError
          # TODO: add logging
        end
      end

      log(file_path) if should_log?
    end
  end

  def delete
    # if DiscScanner return > 1000 files it's quite probable this is correct
    # effect and we can remove files which are in cache but are missing in
    # DiscScanner output

    removed_files = @cache.files.keys - @file_paths

    puts "removed files #{removed_files.size}"
    # puts removed_files.inspect
    # TODO: finish implementation
  end

  def should_log?
    return (@new_files_count % LOG_EVERY_WHEN_NEW_FILE == (LOG_EVERY_WHEN_NEW_FILE - 1)) ||
      (@processed_files_count % LOG_EVERY_EVERY_FILE == (LOG_EVERY_EVERY_FILE - 1))
  end

  def should_save?
    return @processed_file_size > FORCE_SAVE_AFTER_SIZE
  end

  def files_size_to_force_save
    FORCE_SAVE_AFTER_SIZE - @processed_file_size
  end

  def log(file_path)
    puts "#{file_path}:"
    puts "- processed_file_size=#{SizeTools.to_human(@processed_file_size)}"
    puts "- files_size_to_force_save=#{SizeTools.to_human(files_size_to_force_save)}"
    puts "- total_size=#{SizeTools.to_human(@total_size)}"

    puts "- new_files=#{@new_files_count}"
    puts "- updated=#{@updated_files_count}"

    puts "- all_files=#{@processed_files_count}"
    puts "- cached=#{@cache.files.keys.size}"
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
      @processed_file_size = 0.to_i64
    end

    @cache.files[file_path.to_s] = cache_unit
  end
end
