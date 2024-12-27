require "../tools/all"

require "./disk_scanner"

class FullCache::Scanner::ScannedListCache
  def initialize(
    disk : Disk,
    @local_path : String,
    @ignored_paths : Array(String),
    @stats_storage : StatsStorage
  )
    @disk_scanner = DiskScanner.new(
      path: Path.new(disk.path.to_s)
    )
    @scanned_cache_path = "#{@local_path}/#{disk.slug}.scan.yml"
    @file_paths = Array(String).new
  end

  getter :file_paths

  def cache_exists?
    return File.exists?(@scanned_cache_path)
  end

  private def load_cache
    return unless cache_exists?
    @file_paths = Array(String).from_yaml(File.open(@scanned_cache_path))
  end

  private def save_cache
    File.open(@scanned_cache_path, "wb") do |f|
      @file_paths.to_yaml(f)
    end
  end

  def self.is_path_ignored?(file_path, ignored_paths)
    return ignored_paths.select { |ignored_path| file_path.includes?(ignored_path) }.size > 0
  end

  private def create_cache
    @disk_scanner.call
    @file_paths = Array(String).new
    file_paths_to_filter = @disk_scanner.file_paths
    total_ignored_count = 0

    file_paths_to_filter.each do |file_path|
      if self.class.is_path_ignored?(file_path, @ignored_paths)
        # puts "#{time_string} ignoring path #{file_path}"
        total_ignored_count += 1
      else
        @file_paths << file_path
      end
    end

    Lg.info(
      place: self.class,
      message: "filtered out #{total_ignored_count} because of ignored_paths=#{@ignored_paths}"
    )

    Lg.info(
      place: self.class,
      message: "saving scan disk cache #{@file_paths.size}"
    ) do
      save_cache
    end
  end

  def call
    if cache_exists?
      Lg.info(
        place: self.class,
        message: "loading scan disk cache"
      ) do
        load_cache
      end
      Lg.info(
        place: self.class,
        message: "load finished with #{@file_paths.size}"
      )
    else
      Lg.info(
        place: self.class,
        message: "performing scan disk cache"
      ) do
        create_cache
      end
      Lg.info(
        place: self.class,
        message: "perform finished with #{@file_paths.size}"
      )
    end

    @stats_storage.after_scanned_list_cache_load(self)

    return @file_paths
  end

  def total_files_count
    return @file_paths.size
  end
end
