require "./container"
require "./stats"
require "./unit/factories/from_file"
require "./unit/factories/update"

# similar to HashCache but it perform all operation and store
# hash locally. So you can run disk related operation w/o having
# disk connected. WIP
class Scanner::FullCache::Scanner
  # save is forced after processing size and number of files
  FORCE_SAVE_AFTER_SIZE  = 2_000_000_000
  FORCE_SAVE_AFTER_COUNT =         1_000

  LOG_EVERY_WHEN_NEW_FILE =   50
  LOG_EVERY_EVERY_FILE    = 1000

  # TODO: add flag to ignore existing files. This will be new feature
  def initialize(@disk : Disk, @disable_update = true)
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
    @stats = Stats.new

    @was_loaded = false

    # every file which were processed succesfully
    # so if there won't be exception it will increment
    # success mean update attempt but nothing changed
    @processed_succes_files_count = 0
    # as above but it's being reset for logging
    @processed_succes_files_count_for_logging = 0
    # only new files appended to cache
    @processed_new_files_count = 0
    # like above but only succesfull updates (no exception, important change)
    @processed_updated_files_count = 0
    # allow forcing save when amount of files were processed
    # intended for smaller files
    @processed_file_count_for_saving = 0
    # all processed files even the one which not lead to update
    @scanned_file_count = 0
    # as above but only for logging, is being reset
    @scanned_file_count_for_logging = 0

    # added and updated (with something changed) file size
    @processed_file_size = 0.to_i64
    # as above but is being reset after save
    @processed_file_size_for_saving = 0.to_i64
    # size of all files being process even if it's not being updated
    # because it's already on list
    @scanned_file_size = 0.to_i64

    # count of files which is on disk (or in disk semi cache)
    @file_paths_from_disk_count = 0
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
    @file_paths_from_disk_count = @file_paths.size
    @file_paths.sort.each do |file_path|
      t = Time.local
      process_file_path(file_path)
      @stats.append(path: file_path, time_span: Time.local - t)

      log(file_path)
    end
  end

  def process_file_path(file_path)
    if self[file_path]?.nil?
      # file exists but it's not in full cache
      begin
        unit = Unit::Factories::FromFile.new(
          path: file_path
        ).call

        @scanned_file_size += unit.size

        @scanned_file_count += 1
        @scanned_file_count_for_logging += 1

        @processed_succes_files_count += 1
        @processed_succes_files_count_for_logging += 1
        @processed_new_files_count += 1
        @processed_file_count_for_saving += 1
        @processed_file_size += unit.size
        @processed_file_size_for_saving += unit.size

        self[file_path] = unit
      rescue File::NotFoundError
        # TODO: add logging
      end
    else
      # file exists and it's in full cache
      begin
        unit = @cache.files[file_path.to_s]

        unless @disable_update
          update_service = Unit::Factories::Update.new(
            unit: unit,
            path: file_path
          )
          new_unit = update_service.call
          if update_service.update_result
            unit = new_unit
            # only change cache if there was change
            # to not overwrite cache too often
            self[file_path.to_s] = unit

            @processed_succes_files_count += 1
            @processed_succes_files_count_for_logging += 1
            @processed_updated_files_count += 1
            @processed_file_count_for_saving += 1
            @processed_file_size += unit.size
            @processed_file_size_for_saving += unit.size
          end
        end

        @scanned_file_size += unit.size
        @scanned_file_count += 1
        @scanned_file_count_for_logging += 1
      rescue File::NotFoundError
        # TODO: add logging
      end
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

  def should_save?
    if (@processed_file_size_for_saving > FORCE_SAVE_AFTER_SIZE) ||
       (@processed_file_count_for_saving > FORCE_SAVE_AFTER_COUNT)
      @processed_file_size_for_saving = 0.to_i64
      @processed_file_count_for_saving = 0
      return true
    end
    return false
  end

  def files_size_to_force_save
    FORCE_SAVE_AFTER_SIZE - @processed_file_size_for_saving
  end

  def files_count_to_force_save
    FORCE_SAVE_AFTER_COUNT - @processed_file_count_for_saving
  end

  LOGGING_KEY_LENGTH   = 15
  LOGGING_VALUE_LENGTH = 12

  def log(file_path)
    should_log = false
    if @processed_succes_files_count_for_logging >= LOG_EVERY_WHEN_NEW_FILE
      puts "logging because of new/updated files: #{@processed_succes_files_count}/#{@processed_succes_files_count_for_logging}"
      should_log = true
      @processed_succes_files_count_for_logging = 0
    end

    if @scanned_file_count_for_logging >= LOG_EVERY_EVERY_FILE
      puts "logging because of total files scanned: #{@scanned_file_count}/#{@scanned_file_count_for_logging}"
      should_log = true
      @scanned_file_count_for_logging = 0
    end

    return unless should_log

    log_string = String.build do |s|
      s << "** #{file_path}:"
      s << "iterated\n"

      iterated_percent = ((@processed_succes_files_count.to_f / (@file_paths_from_disk_count + 1).to_f) * 100.0).round / 10.0
      string = "percent".rjust(LOGGING_KEY_LENGTH) + ": " + "#{iterated_percent}%".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "count".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_succes_files_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "processed".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@file_paths_from_disk_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "in cache".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@cache.files.keys.size}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      string = "new".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_new_files_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "updated".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_updated_files_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      string = "in iteration".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_file_count_for_saving}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "to save".rjust(LOGGING_KEY_LENGTH) + ": " + "#{files_count_to_force_save}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "size".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@processed_file_size_for_saving)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "to save".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(files_size_to_force_save)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@scanned_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      s << string
    end

    puts log_string
  end

  def []?(file_path)
    load unless @was_loaded
    return @cache.files[file_path.to_s]?
  end

  def []=(file_path, cache_unit)
    if should_save?
      save
      @stats.print
    end

    @cache.files[file_path.to_s] = cache_unit
  end
end
