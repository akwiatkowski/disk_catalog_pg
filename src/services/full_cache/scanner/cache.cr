require "../factories/container_factory"

require "./processors/main"

#
class FullCache::Scanner::Cache
  def initialize(
    @disk : Disk,
    @local_path : String,
    @stats_storage : StatsStorage,
    @ignored_paths : Array(String)? = nil
  )
    @cache_path = "#{@local_path}/#{disk.slug}.yml"
    @backup_cache_path = "#{@local_path}/#{disk.slug}.yml.bak"

    @container = Factories::ContainerFactory.from_disk(
      disk: @disk
    ).as(Models::Container)
  end

  def rescan_file_path(file_path : String)
    existing_unit = @container[file_path]?
    processor = Processors::Main.new(
      file_path: file_path,
      existing_unit: existing_unit
    )
    new_unit = processor.call
    if new_unit
      # get new instance and update in container
      Lg.info(
        place: self.class,
        message: "updating",
        path: file_path
      )
      @container[file_path] = new_unit

      @stats_storage.after_updating_unit(
        unit: new_unit
      )
    else
      # nothing
      @stats_storage.after_not_updating_unit(
        unit: existing_unit.not_nil!
      )
    end
  end

  def cache_exists?
    return File.exists?(@cache_path)
  end

  def load
    call
  end

  def call
    if cache_exists?
      Lg.info(
        place: self.class,
        message: "loading disk cache",
        path: @cache_path
      ) do
        load_cache
      end
      Lg.important(
        place: self.class,
        message: "load finished with #{@container.total_file_count} files, #{SizeTools.to_human(@container.total_file_size)}"
      )
    else
      create_cache
      Lg.info(
        place: self.class,
        message: "created disk cache because not exist"
      )
    end

    @stats_storage.after_cache_load(self)
  end

  def save
    Lg.important(
      place: self.class,
      message: "saving disk cache with #{@container.total_file_count}",
      path: @cache_path
    ) do
      save_cache
    end
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

  def total_files_size
    return @container.total_file_size
  end

  def total_files_count
    return @container.total_file_count
  end

  private def load_cache
    return unless cache_exists?
    @container = Factories::ContainerFactory.from_cache_path(
      path: @cache_path,
      ignored_paths: @ignored_paths
    )
  end

  private def create_cache
    @container = Factories::ContainerFactory.from_disk(
      disk: @disk,
      ignored_paths: @ignored_paths
    )
  end

  private def save_cache
    if File.exists?(@cache_path)
      File.rename(
        old_filename: @cache_path,
        new_filename: @backup_cache_path
      )
      Lg.debug(
        place: self.class,
        message: "renamed #{@cache_path} to #{@backup_cache_path}"
      )
    end

    File.open(@cache_path, "wb") do |f|
      @container.to_yaml(f)
    end
  end
end
