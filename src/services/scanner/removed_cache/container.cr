struct Scanner::RemovedCache::Container
  include YAML::Serializable

  @name : String
  @path : String
  @file_paths : Array(String)
  @last_cache_time : Time
  @total_files_checked : Int32

  getter :file_paths

  def initialize(disk)
    @name = disk.name.not_nil!
    @path = disk.path.not_nil!
    @file_paths = Array(String).new
    @last_cache_time = Time.local
    @total_files_checked = 0
  end

  def reset_last_cache_time!(total_files_checked)
    @total_files_checked = total_files_checked
    @last_cache_time = Time.local
  end
end
