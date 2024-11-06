require "./unit"

struct Scanner::FullCache::Container
  include YAML::Serializable

  @name : String
  @path : String
  @files : Hash(String, Unit)
  @last_cache_time : Time
  @total_disk_size : Int64?
  @avail_disk_size : Int64?

  getter :files

  def initialize(disk)
    @name = disk.name.not_nil!
    @path = disk.path.not_nil!
    @files = Hash(String, Unit).new
    @last_cache_time = Time.local
    @total_disk_size = disk_size_for_disk(disk)
    @avail_disk_size = disk_free_size_for_disk(disk)

    puts "disk #{disk.path}, total_size=#{SizeTools.to_human(@total_disk_size)}, avail_size=#{SizeTools.to_human(@avail_disk_size)}"
  end

  def reset_last_cache_time!
    @last_cache_time = Time.local
  end

  def disk_size_for_disk(disk)
    command = "df --output=size -BM #{disk.path}"
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[1][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end

  def disk_free_size_for_disk(disk)
    command = "df --output=avail -BM #{disk.path}"
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[0][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end
end
