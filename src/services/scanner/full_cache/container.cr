require "./unit"

struct Scanner::FullCache::Container
  include YAML::Serializable

  @name : String
  @path : String
  @files : Hash(String, Unit)
  @last_cache_time : Time

  getter :files

  def initialize(disk)
    @name = disk.name.not_nil!
    @path = disk.path.not_nil!
    @files = Hash(String, Unit).new
    @last_cache_time = Time.local
  end

  def reset_last_cache_time!
    @last_cache_time = Time.local
  end
end
