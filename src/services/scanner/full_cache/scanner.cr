require "./container"
require "./stats"
require "./unit/factories/from_file"
require "./unit/factories/update"

# similar to HashCache but it perform all operation and store
# hash locally. So you can run disk related operation w/o having
# disk connected. WIP
class Scanner::FullCache::Scanner
  # save is forced after processing size and number of files
  FORCE_SAVE_AFTER_SIZE  = 10_000_000_000
  FORCE_SAVE_AFTER_COUNT =          4_000

  LOG_EVERY_SECONDS = 20
  # SAVE_MIN_INTERVAL = 50
  # SAVE_MAX_INTERVAL = 240

  SAVE_MIN_INTERVAL =  5
  SAVE_MAX_INTERVAL = 20

  # TODO: add flag to ignore existing files. This will be new feature
  def initialize(
    @disk : Disk,
    @disable_update = true,
    @ignored_paths = Array(String).new
  )
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
    # only new files appended to cache
    @processed_new_files_count = 0
    # like above but only succesfull updates (no exception, important change)
    @processed_updated_files_count = 0
    # allow forcing save when amount of files were processed
    # intended for smaller files
    @processed_file_count_for_saving = 0
    # all processed files even the one which not lead to update
    @scanned_file_count = 0
    # file which exists and should be identical, skipping
    @unmodified_file_count = 0

    # added and updated (with something changed) file size
    @processed_file_size = 0.to_i64
    # as above but is being reset after save
    @processed_file_size_for_saving = 0.to_i64
    # size of all files being process even if it's not being updated
    # because it's already on list
    @scanned_file_size = 0.to_i64
    # size of all files which are already in cache which is loaded
    @loaded_file_size = 0.to_i64
    # file which exists and should be identical, skipping
    @unmodified_file_size = 0.to_i64
    # diff between disk size and available free space
    # not available on every scanned disk
    @files_on_disk_size = 0.to_i64
    # calculated using size of all unit from cache and then
    # incremented when adding new file
    @cached_size = 0.to_i64

    # count of files which is on disk (or in disk semi cache)
    @file_paths_from_disk_count = 0
    # increment every iteration
    # there should be similar variable but this one should works
    # better because it's not impacted by logic and exceptions
    @file_paths_iteration = 0

    @last_log_time = Time.local
    @last_save_time = Time.local
  end

  getter :cache

  def time_string
    return Time.local.to_s("%y-%m-%d %H:%M:%S.%3N")
  end

  def load
    if File.exists?(@cache_path)
      @cache = Container.from_yaml(File.open(@cache_path))
      @loaded_file_size = @cache.total_file_size
    end
    @was_loaded = true
  end

  def scan_disk_or_load_cache
    if File.exists?(@scanned_cache_path)
      puts "#{time_string} loading scan disk cache"
      @file_paths = Array(String).from_yaml(File.open(@scanned_cache_path))
      puts "#{time_string} load finished #{@file_paths.size}"
    else
      @disk_scanner.make_it_so
      @file_paths = Array(String).new
      file_paths = @disk_scanner.file_paths

      file_paths.each do |file_path|
        ignored_count = @ignored_paths.select { |ignored_path| file_path.includes?(ignored_path) }.size
        if ignored_count > 0
          puts "#{time_string} ignoring path #{file_path}"
        else
          @file_paths << file_path
        end
      end

      puts "#{time_string} saving scan disk cache #{@file_paths.size}"
      save_disk_scan
      puts "#{time_string} save finished #{@file_paths.size}"
    end

    return @file_paths
  end

  def get_disk_size
    @cache.get_disk_sizes
    if @cache.total_disk_size && @cache.avail_disk_size
      @files_on_disk_size = @cache.total_disk_size.not_nil! - @cache.avail_disk_size.not_nil!
    end

    @cache.files.values.each do |unit|
      @cached_size += unit.size
    end
  end

  def save_disk_scan
    File.open(@scanned_cache_path, "wb") do |f|
      @file_paths.to_yaml(f)
    end
    puts "#{time_string} scanned disk cache save completed"
  end

  def save
    log("")

    # cache should hold all files. It will be filtered later
    # before saving them to DB

    # just for backup
    File.rename(
      old_filename: @cache_path,
      new_filename: "#{@cache_path}.bak"
    ) if File.exists?(@cache_path)

    puts "#{time_string} save cache_path=#{@cache_path}"
    File.open(@cache_path, "w") do |f|
      @cache.to_yaml(f)
    end
    puts "#{time_string} save completed"

    @last_save_time = Time.local
    @processed_file_size_for_saving = 0.to_i64
    @processed_file_count_for_saving = 0
  end

  def reset
    @cache = Container.new(@disk)
  end

  def make_it_so
    unless File.exists?(@disk_path)
      puts "#{time_string} path not mounted"
      return
    end

    get_disk_size
    scan_disk_or_load_cache
    insert_and_update
    delete

    @cache.reset_last_cache_time!
    save
  end

  def insert_and_update
    @file_paths_from_disk_count = @file_paths.size
    @file_paths.sort.each do |file_path|
      @file_paths_iteration += 1

      process_file_path(file_path)

      check_and_save(file_path)
      log(file_path)
    end
  end

  def process_file_path(file_path)
    if self[file_path]?.nil?
      # file exists but it's not in full cache
      # NEW
      begin
        unit = Unit::Factories::FromFile.new(
          path: file_path
        ).call

        @scanned_file_size += unit.size
        @scanned_file_count += 1

        @processed_succes_files_count += 1
        @processed_new_files_count += 1
        @processed_file_count_for_saving += 1
        @processed_file_size += unit.size
        @processed_file_size_for_saving += unit.size
        @cached_size += unit.size

        self[file_path] = unit
      rescue File::NotFoundError
        # TODO: add logging
      rescue File::AccessDeniedError
        # TODO: add logging
      end
    else
      # file exists and it's in full cache
      # UPDATE
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
            @processed_updated_files_count += 1
            @processed_file_count_for_saving += 1
            @processed_file_size += unit.size
            @processed_file_size_for_saving += unit.size
          else
            @unmodified_file_count += 1
            @unmodified_file_size += unit.size
          end
        end

        @scanned_file_size += unit.size
        @scanned_file_count += 1
      rescue File::NotFoundError
        # TODO: add logging
      rescue File::AccessDeniedError
        # TODO: add logging
      end
    end
  end

  def delete
    # if DiscScanner return > 1000 files it's quite probable this is correct
    # effect and we can remove files which are in cache but are missing in
    # DiscScanner output

    removed_files = @cache.files.keys - @file_paths

    puts "#{time_string} removed files #{removed_files.size}"
    # puts removed_files.inspect
    # TODO: finish implementation
  end

  def save_interval_seconds
    return (Time.local - @last_save_time).total_seconds.to_i
  end

  def should_save_and_log?
    # fix for oftren save
    return false if save_interval_seconds < SAVE_MIN_INTERVAL
    return true if save_interval_seconds >= SAVE_MAX_INTERVAL

    if (@processed_file_size_for_saving > FORCE_SAVE_AFTER_SIZE) ||
       (@processed_file_count_for_saving > FORCE_SAVE_AFTER_COUNT)
      return true
    end
    return false
  end

  def should_log?
    return (Time.local - @last_log_time).total_seconds >= LOG_EVERY_SECONDS
  end

  def log(file_path)
    return unless should_log?
    @last_log_time = Time.local

    log_string = String.build do |s|
      s << "#{time_string} #{file_path}:\n"

      # new, most important
      # 1. percentage count - how much we processed path from scanned from disk
      file_path_from_disk_count = [@file_paths_from_disk_count, 1].max
      percentage = ((@file_paths_iteration.to_f / file_path_from_disk_count.to_f) * 1000.0).round / 10.0

      string = "count %".rjust(LOGGING_KEY_LENGTH) + ": " + "#{percentage}%".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@file_paths_from_disk_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "in cache".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@cache.files.keys.size}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "iteration".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@file_paths_iteration}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      # 2. percentage size - how much we processed in size not file count
      # drawback here is that we don't know

      # 2a. size of files on disk using total disk size - available
      if @files_on_disk_size > 0
        percentage = ((@scanned_file_size.to_f / @files_on_disk_size.to_f) * 1000.0).round / 10.0

        string = "size on disk %".rjust(LOGGING_KEY_LENGTH) + ": " + "#{percentage}%".ljust(LOGGING_VALUE_LENGTH)
        s << string

        string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@scanned_file_size)}".ljust(LOGGING_VALUE_LENGTH)
        s << string

        string = "files on disk".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@files_on_disk_size)}".ljust(LOGGING_VALUE_LENGTH)
        s << string

        s << "\n"
      end

      # 2b. size of files alreacy scanned
      if @cached_size > 0
        percentage = ((@scanned_file_size.to_f / @cached_size.to_f) * 1000.0).round / 10.0

        string = "size by cached %".rjust(LOGGING_KEY_LENGTH) + ": " + "#{percentage}%".ljust(LOGGING_VALUE_LENGTH)
        s << string

        string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@scanned_file_size)}".ljust(LOGGING_VALUE_LENGTH)
        s << string

        string = "cached size".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@cached_size)}".ljust(LOGGING_VALUE_LENGTH)
        s << string

        s << "\n"
      end

      # 3. how many new, updated or identical
      string = "new".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_new_files_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "updated".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_updated_files_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "unmodified".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@unmodified_file_count}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "unmod.size".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@unmodified_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      # 4
      string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@scanned_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "loaded".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@loaded_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      if @cache.total_disk_size
        string = "total disk".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@cache.total_disk_size.not_nil!)}".ljust(LOGGING_VALUE_LENGTH)
        s << string
      end

      if @cache.avail_disk_size
        string = "free avail".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@cache.avail_disk_size.not_nil!)}".ljust(LOGGING_VALUE_LENGTH)
        s << string
      end

      if @cache.total_disk_size && @cache.avail_disk_size
        taken_size_on_disk = @cache.total_disk_size.not_nil! - @cache.avail_disk_size.not_nil!
        to_scan_size = taken_size_on_disk - @scanned_file_size

        string = "to scan".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(to_scan_size)}".ljust(LOGGING_VALUE_LENGTH)
        s << string
      end

      s << "\n"

      string = "in iteration".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_file_count_for_saving}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "to save".rjust(LOGGING_KEY_LENGTH) + ": " + "#{files_count_to_force_save}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "size".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@processed_file_size_for_saving)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "to save".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(files_size_to_force_save)}".ljust(LOGGING_VALUE_LENGTH)
      s << string

      string = "saved ago".rjust(LOGGING_KEY_LENGTH) + ": " + "#{save_interval_seconds}s".ljust(LOGGING_VALUE_LENGTH)
      s << string

      s << "\n"

      # file_path_from_disk_count = [@file_paths_from_disk_count, 1].max
      # percentage ((@scanned_file_size.to_f / file_path_from_disk_count.to_f) * 100.0).round / 10.0
      # # 2. size of iterated files - how much of disk we processed
      #
      #
      # # old, detailed
      # iterated_percent = ((@processed_succes_files_count.to_f / (@file_paths_from_disk_count + 1).to_f) * 100.0).round / 10.0
      # string = "(iter.) percent".rjust(LOGGING_KEY_LENGTH) + ": " + "#{iterated_percent}%".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "count".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_succes_files_count}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "processed".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@file_paths_from_disk_count}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "in cache".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@cache.files.keys.size}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # s << "\n"
      #
      # string = "new".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_new_files_count}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "updated".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@processed_updated_files_count}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "unmodified".rjust(LOGGING_KEY_LENGTH) + ": " + "#{@unmodified_file_count}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "unmod.size".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@unmodified_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # s << "\n"
      #

      #
      # string = "scanned".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@scanned_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # string = "loaded".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@loaded_file_size)}".ljust(LOGGING_VALUE_LENGTH)
      # s << string
      #
      # if @cache.total_disk_size
      #   string = "total disk".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@cache.total_disk_size.not_nil!)}".ljust(LOGGING_VALUE_LENGTH)
      #   s << string
      # end
      #
      # if @cache.avail_disk_size
      #   string = "free avail".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(@cache.avail_disk_size.not_nil!)}".ljust(LOGGING_VALUE_LENGTH)
      #   s << string
      # end
      #
      # if @cache.total_disk_size && @cache.avail_disk_size
      #   taken_size_on_disk = @cache.total_disk_size.not_nil! - @cache.avail_disk_size.not_nil!
      #   to_scan_size = taken_size_on_disk - @scanned_file_size
      #
      #   string = "to scan".rjust(LOGGING_KEY_LENGTH) + ": " + "#{SizeTools.to_human(to_scan_size)}".ljust(LOGGING_VALUE_LENGTH)
      #   s << string
      # end
    end
    puts log_string
  end

  def files_size_to_force_save
    FORCE_SAVE_AFTER_SIZE - @processed_file_size_for_saving
  end

  def files_count_to_force_save
    FORCE_SAVE_AFTER_COUNT - @processed_file_count_for_saving
  end

  LOGGING_KEY_LENGTH   = 15
  LOGGING_VALUE_LENGTH = 12

  def []?(file_path)
    load unless @was_loaded
    return @cache.files[file_path.to_s]?
  end

  def check_and_save(file_path)
    if should_save_and_log?
      log(file_path)
      save
      # this one is not that usefule that I thought
      # @stats.print
    end
  end

  def []=(file_path, cache_unit)
    puts "before: #{@cache.files[file_path.to_s].taken_at.inspect}"
    puts "after: #{cache_unit.taken_at.inspect}"

    @cache.files[file_path.to_s] = cache_unit

    check_and_save(file_path)
  end
end
