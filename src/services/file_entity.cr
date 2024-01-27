require "digest/md5"

struct FileEntity
  def initialize(@path : Path)
    @size = 0.to_i64
    @modification_time = Time.local
    @is_directory = false
    @hash = ""

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

  getter :path, :size, :modification_time, :is_directory

  def hash
    if @hash == ""
      @hash = self.class.hash_for_path(@path).as(String)
    end

    return @hash
  end

  def self.hash_for_path(path)
    # Digest::MD5.new(File.read(path)).hexfinal or something
    command = "md5sum \"#{path}\""
    result = `#{command}`
    hash = result.split(/\s/)[0]
    return hash
  end
end
