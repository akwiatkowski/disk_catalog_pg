require "./unit"

struct FullCache::Models::Container
  include YAML::Serializable

  @name : String
  @path : String
  @files : Hash(String, Unit)
  @last_cache_time : Time
  @total_disk_size : Int64?
  @avail_disk_size : Int64?
  @ignored_paths : Array(String)?

  getter :path, :total_disk_size, :avail_disk_size

  def initialize(
    @name : String,
    @path : String,
    @total_disk_size : Int64,
    @avail_disk_size : Int64,
    @ignored_paths : Array(String)?
  )
    @files = Hash(String, Unit).new
    @last_cache_time = Time.local
  end

  def reset_last_cache_time!
    @last_cache_time = Time.local
  end

  # I prefered to have not mutable objects but because of
  # @files are not accessed directly and copying whole container could
  # be memory inefficient it's better to leave as it is.
  #
  # TODO: think if it would be better to move actual disk related code here
  # instead of in factory
  def update_disk_sizes!(size_tupple)
    @total_disk_size = size_tupple[:total_disk_size].not_nil!
    @avail_disk_size = size_tupple[:avail_disk_size].not_nil!
  end

  def update_ignored_paths!(ignored_paths)
    @ignored_paths = ignored_paths
  end

  def total_file_size
    size = 0.to_i64
    @files.values.each do |unit|
      size += unit.size.not_nil! unless unit.size.nil?
    end
    return size
  end

  def total_file_count
    return @files.values.size
  end

  def []?(file_path)
    @files[file_path]?
  end

  def []=(file_path, new_unit)
    @files[file_path] = new_unit
  end
end
