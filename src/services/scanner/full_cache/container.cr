require "./unit/entity"

struct Scanner::FullCache::Container
  include YAML::Serializable

  @name : String
  @path : String
  @files : Hash(String, Unit::Entity)
  @last_cache_time : Time
  @total_disk_size : Int64?
  @avail_disk_size : Int64?

  getter :files, :total_disk_size, :avail_disk_size

  def initialize(disk)
    @name = disk.name.not_nil!
    @path = disk.path.not_nil!
    @last_cache_time = Time.local
    @total_disk_size = 0
    @avail_disk_size = 0
    @files = Hash(String, Unit::Entity).new

    if File.exists?(@path)
      begin
        @total_disk_size = disk_size_for_disk(disk.path)
        @avail_disk_size = disk_free_size_for_disk(disk.path)
      rescue IndexError
        puts "problem with getting disk size"
      end
      puts "disk #{disk.path}, total_size=#{SizeTools.to_human(@total_disk_size)}, avail_size=#{SizeTools.to_human(@avail_disk_size)}"
    end
  end

  def reset_last_cache_time!
    @last_cache_time = Time.local
  end

  def get_disk_sizes
    if File.exists?(@path)
      @total_disk_size ||= disk_size_for_disk(@path)
      @avail_disk_size ||= disk_free_size_for_disk(@path)
    end
  end

  def disk_size_for_disk(disk_path)
    command = "df --output=size -BM \"#{disk_path}\""
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[1][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end

  def disk_free_size_for_disk(disk_path)
    command = "df --output=avail -BM \"#{disk_path}\""
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[0][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end

  def total_file_size
    size = 0.to_i64
    @files.values.each do |unit|
      size += unit.size
    end
    return size
  end
end
