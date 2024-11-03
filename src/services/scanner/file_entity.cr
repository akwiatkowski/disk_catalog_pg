require "digest/md5"

require "./hash_cache"

struct FileEntity
  def initialize(@path : Path, @cache_unit : Scanner::FullCache::Unit? = nil)
    if @cache_unit
      # if @cache_unit is provided it doesn't touch disk!

      cu = @cache_unit.not_nil!

      @size = cu.size
      @modification_time = cu.modification_time
      @is_directory = cu.is_directory
      @hash = cu.hash
      @mime_type = cu.mime_type
    else
      # regular way, when disk access
      # it takes a lot of time because of hash generation
      @size = 0.to_i64
      @modification_time = Time.local
      @is_directory = false
      @hash = ""
      @mime_type = ""

      begin
        @size = File.size(@path).to_i64
        if @size > 100_000_000_000
          # error with file size, some special file
          @size = 0
        end

        info = File.info(@path)
        @modification_time = info.modification_time.as(Time)
        @is_directory = info.directory?.as(Bool)
      rescue File::NotFoundError
        puts "file not found: #{@path}"
      rescue File::AccessDeniedError
        puts "file access denied: #{@path}"
      end
    end
  end

  getter :path, :size, :modification_time, :is_directory

  def hash
    if @hash == ""
      @hash = self.class.hash_for_path(@path).as(String)
    end

    return @hash
  end

  def mime_type
    if @mime_type == ""
      mime_command = "file --mime-type \"#{@path}\""
      mime_result = `#{mime_command}`
      @mime_type = mime_result.gsub(/[^:]+: /, "").strip
    end

    return @mime_type
  end

  def basename
    return @path.basename
  end

  def file_extension
    return @path.extension.gsub(/^\./, "").to_s.downcase
  end

  def self.hash_for_path(path)
    caches_hash = Scanner::HashCache[path]?
    return caches_hash if caches_hash

    # crystal is a bit faster
    hash = hash_for_path_crystal(path)
    # hash = hash_for_path_command(path)

    Scanner::HashCache[path] = hash

    return hash
  end

  def self.hash_for_path_command(path)
    command = "md5sum \"#{path}\""
    result = `#{command}`
    hash = result.split(/\s/)[0]
    return hash
  end

  def self.hash_for_path_crystal(path)
    return Digest::MD5.new.file(path).hexfinal
  end
end
