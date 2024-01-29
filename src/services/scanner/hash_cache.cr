class Scanner::HashCache
  FORCE_SAVE_AFTER = 500
  DEBUG_PUTS       = false

  alias CacheHash = Hash(String, String)

  @@cache_path = "hash.yml"
  @@cache = CacheHash.new

  @@was_loaded = false
  @@counter_for_save = 0

  def self.[]?(path)
    puts "get #{path}, i=#{@@counter_for_save}, keys=#{@@cache.keys.size}" if DEBUG_PUTS

    load unless @@was_loaded
    return @@cache[path.to_s]?
  end

  def self.[]=(path, value)
    puts "set #{path}, i=#{@@counter_for_save}, keys=#{@@cache.keys.size}" if DEBUG_PUTS

    @@counter_for_save += 1
    if @@counter_for_save > FORCE_SAVE_AFTER
      save
      @@counter_for_save = 0
    end

    @@cache[path.to_s] = value
  end

  def self.save
    File.open(@@cache_path, "w") do |f|
      @@cache.to_yaml(f)
    end
  end

  def self.load
    if File.exists?(@@cache_path)
      @@cache = CacheHash.from_yaml(File.open(@@cache_path))
    end

    @@was_loaded = true
  end

  def self.reset
    @@cache = CacheHash.new
  end

  def self.cache_path=(new_path)
    @@cache_path = new_path
  end
end
