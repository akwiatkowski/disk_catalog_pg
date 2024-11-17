require "./file_entity_processors/hash"

# TODO: refactor it
# maybe factory pattern?
# move size, mime, somewhere else to have only struct here

struct Scanner::FileEntity
  extend FileEntityProcessors::Hash

  @size = 0.to_i64
  @modification_time = Time.local
  @is_directory = false
  @hash = ""
  @mime_type = ""
  @taken_at : Time?

  def initialize(
    @path : Path,
    @cache_unit : Scanner::FullCache::Unit? = nil
  )
    if @cache_unit
      # if @cache_unit is provided it doesn't touch disk!
      initialize_from_cache_unit(@cache_unit.not_nil!)
    else
      # regular way, when disk access
      # it takes a lot of time because of hash generation
      initialize_from_real_file
    end
  end

  private def initialize_from_cache_unit(cache_unit)
    @size = cache_unit.size
    @modification_time = cache_unit.modification_time
    @is_directory = cache_unit.is_directory
    @hash = cache_unit.hash
    @mime_type = cache_unit.mime_type
    @taken_at = cache_unit.taken_at
  end

  private def initialize_from_real_file
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

  # TODO DRY
  def file_extension
    return @path.extension.gsub(/^\./, "").to_s.downcase
  end

  MIME_FOR_TAKEN_AT = ["image/jpeg", "image/x-olympus-orf", "image/tiff"]
  EXTS_FOR_TAKEN_AT = [
    "jpg", "jpeg", "arw", "pef", "dng", "orf", "ori",
    "ari", "crw", "gpr", "nef", "nrw", "raf",
  ]
  LOCAL_LOCATION = Time::Location.load("Europe/Warsaw")

  def taken_at
    # filtering by mime is not the best because a lot of file contains
    # tiff for a thumbnail, like mp4 files
    # cat *.yml | grep mime | sort | uniq
    # if MIME_FOR_TAKEN_AT.includes?(mime_type)

    if @taken_at.nil?
      if EXTS_FOR_TAKEN_AT.includes?(file_extension)
        command = "exiftool -T -DateTimeOriginal \"#{@path}\""
        result = `#{command}` # 2019:10:12 20:00:45
        begin
          @taken_at = Time.parse(
            result,
            "%Y:%m:%d %H:%M:%S",
            LOCAL_LOCATION
          )
        rescue Time::Format::Error
          # a lot of file contain tiff like a thumbnail but we don't want
          # puts "Time::Format::Error - #{result} @ #{@path}"
        rescue ArgumentError
          # lets ignore this
        end
        # puts "#{@path} - #{@taken_at}"
      end
    end

    return @taken_at
  end
end
