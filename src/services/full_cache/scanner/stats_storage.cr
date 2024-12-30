class FullCache::Scanner::StatsStorage
  def initialize(
    @lg : Ui::Lg
  )
    # for speed calculation # TODO
    @start_time = Time.local

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

    @missed_keys_count = Hash(String, Int32).new
    @missed_keys_time = Hash(String, Time).new
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
    @lg.debug(
      place: self.class,
      message: "loaded_scanned_cache_files_count=#{@loaded_scanned_cache_files_count}"
    )
  end

  def after_cache_load(cache : Cache)
    @loaded_cache_files_count = cache.total_files_count
    @lg.debug(
      place: self.class,
      message: "loaded_cache_files_count=#{@loaded_cache_files_count}"
    )

    @loaded_cache_files_size = cache.total_files_size
    @lg.debug(
      place: self.class,
      message: "loaded_cache_files_size=#{size_to_h(@loaded_cache_files_size)}"
    )
  end

  def after_updating_unit(unit : Models::Unit)
    @processed_files_count += 1
    @lg.debug(
      place: self.class,
      message: "processed_files_count=#{@processed_files_count}"
    )

    @updated_units_count += 1
    @lg.debug(
      place: self.class,
      message: "updated_units_count=#{@updated_units_count}"
    )

    if unit.size
      @processed_files_size += unit.size.not_nil!
      @lg.debug(
        place: self.class,
        message: "processed_files_size=#{size_to_h(@processed_files_size)}"
      )
      @updated_units_size += unit.size.not_nil!
      @lg.debug(
        place: self.class,
        message: "updated_units_size=#{size_to_h(@updated_units_size)}"
      )
    end
  end

  def after_not_updating_unit(unit : Models::Unit)
    @processed_files_count += 1
    @lg.debug(
      place: self.class,
      message: "processed_files_count=#{@processed_files_count}"
    )

    @identical_units_count += 1
    @lg.debug(
      place: self.class,
      message: "identical_units_count=#{@identical_units_count}"
    )

    if unit.size
      @processed_files_size += unit.size.not_nil!
      @lg.debug(
        place: self.class,
        message: "processed_files_size=#{size_to_h(@processed_files_size)}"
      )
      @identical_units_size += unit.size.not_nil!
      @lg.debug(
        place: self.class,
        message: "identical_units_size=#{size_to_h(@identical_units_size)}"
      )
    end
  end

  def missed_key(key)
    if @missed_keys_count[key]?.nil?
      @missed_keys_count[key] = 0
      @missed_keys_time[key] = Time.local
    end

    @missed_keys_count[key] += 1
    @missed_keys_time[key] = Time.local
  end

  def to_h_missed_keys
    result = Hash(String, String).new
    @missed_keys_count.keys.each do |key|
      result[key] = "#{@missed_keys_count[key]} (#{@missed_keys_time[key].to_s("%H:%M:%S.%3N")})"
    end
    return result
  end

  def to_h_additional
    {
      to_go: @loaded_scanned_cache_files_count - @processed_files_count,
    }
  end

  def size_to_h(size)
    SizeTools.to_human(size)
  end
end
