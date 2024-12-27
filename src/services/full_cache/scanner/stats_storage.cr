class FullCache::Scanner::StatsStorage
  def initialize
    # size of all files which exists on disk
    @loaded_scanned_cache_files_count = 0

    # size of all files which were already in cache which was loaded
    @loaded_cache_files_count = 0
    @loaded_cache_files_size = 0.to_i64

    # when iterating by files on disk (or ScannedListCache)
    # increment by every case
    @processed_files_count = 0
    @processed_files_size = 0.to_i64
    # when file was changed and it will update in Cache
    @updated_units_count = 0
    @updated_units_size = 0.to_i64
    # when it was identical (size + modification_time)
    @identical_units_count = 0
    @identical_units_size = 0.to_i64
  end

  getter :loaded_cache_file_size,
    :processed_files_count,
    :processed_files_size,
    :updated_units_count,
    :updated_units_size,
    :identical_units_count,
    :identical_units_size

  def to_h
    {
      loaded_scanned_cache_files_count: @loaded_scanned_cache_files_count,
      loaded_cache_files_count:         @loaded_cache_files_count,
      loaded_cache_files_size:          size_to_h(@loaded_cache_files_size),
      processed_files_count:            @processed_files_count,
      processed_files_size:             size_to_h(@processed_files_size),
      updated_units_count:              @updated_units_count,
      updated_units_size:               size_to_h(@updated_units_size),
      identical_units_count:            @identical_units_count,
      identical_units_size:             size_to_h(@identical_units_size),
    }
  end

  def after_scanned_list_cache_load(scanned_list_cache : ScannedListCache)
    @loaded_scanned_cache_files_count = scanned_list_cache.total_files_count
    Lg.debug(
      place: self.class,
      message: "loaded_scanned_cache_files_count=#{@loaded_scanned_cache_files_count}"
    )
  end

  def after_cache_load(cache : Cache)
    @loaded_cache_files_count = cache.total_files_count
    Lg.debug(
      place: self.class,
      message: "loaded_cache_files_count=#{@loaded_cache_files_count}"
    )

    @loaded_cache_files_size = cache.total_files_size
    Lg.debug(
      place: self.class,
      message: "loaded_cache_files_size=#{size_to_h(@loaded_cache_files_size)}"
    )
  end

  def after_updating_unit(unit : Models::Unit)
    @processed_files_count += 1
    Lg.debug(
      place: self.class,
      message: "processed_files_count=#{@processed_files_count}"
    )

    @updated_units_count += 1
    Lg.debug(
      place: self.class,
      message: "updated_units_count=#{@updated_units_count}"
    )

    if unit.size
      @processed_files_size += unit.size.not_nil!
      Lg.debug(
        place: self.class,
        message: "processed_files_size=#{size_to_h(@processed_files_size)}"
      )
      @updated_units_size += unit.size.not_nil!
      Lg.debug(
        place: self.class,
        message: "updated_units_size=#{size_to_h(@updated_units_size)}"
      )
    end
  end

  def after_not_updating_unit(unit : Models::Unit)
    @processed_files_count += 1
    Lg.debug(
      place: self.class,
      message: "processed_files_count=#{@processed_files_count}"
    )

    @identical_units_count += 1
    Lg.debug(
      place: self.class,
      message: "identical_units_count=#{@identical_units_count}"
    )

    if unit.size
      @processed_files_size += unit.size.not_nil!
      Lg.debug(
        place: self.class,
        message: "processed_files_size=#{size_to_h(@processed_files_size)}"
      )
      @identical_units_size += unit.size.not_nil!
      Lg.debug(
        place: self.class,
        message: "identical_units_size=#{size_to_h(@identical_units_size)}"
      )
    end
  end

  def size_to_h(size)
    SizeTools.to_human(size)
  end

  #   :cached_size,
  #   :file_paths_from_disk_count,
  #   :file_paths_iteration,
  #   :last_log_time,
  #   :last_save_time
  #
  # def initialize
  #   # every file which were processed succesfully
  #   # so if there won't be exception it will increment
  #   # success mean update attempt but nothing changed
  #    = 0
  #   # only new files appended to cache
  #   @processed_new_files_count = 0
  #   # like above but only succesfull updates (no exception, important change)
  #   @processed_updated_files_count = 0
  #   # allow forcing save when amount of files were processed
  #   # intended for smaller files
  #   @processed_file_count_for_saving = 0
  #   # all processed files even the one which not lead to update
  #   @scanned_file_count = 0
  #   # file which exists and should be identical, skipping
  #   @unmodified_file_count = 0
  #
  #   # added and updated (with something changed) file size
  #   @processed_file_size = 0.to_i64
  #   # as above but is being reset after save
  #   @processed_file_size_for_saving = 0.to_i64
  #   # size of all files being process even if it's not being updated
  #   # because it's already on list
  #   @scanned_file_size = 0.to_i64

  #   # file which exists and should be identical, skipping
  #   @unmodified_file_size = 0.to_i64
  #   # diff between disk size and available free space
  #   # not available on every scanned disk
  #   @files_on_disk_size = 0.to_i64
  #   # calculated using size of all unit from cache and then
  #   # incremented when adding new file
  #   @cached_size = 0.to_i64
  #
  #   # count of files which is on disk (or in disk semi cache)
  #   @file_paths_from_disk_count = 0
  #   # increment every iteration
  #   # there should be similar variable but this one should works
  #   # better because it's not impacted by logic and exceptions
  #   @file_paths_iteration = 0
  #
  #   @last_log_time = Time.local
  #   @last_save_time = Time.local
  # end

end
