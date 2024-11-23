require "./processors/basic_processor"
require "./processors/size_processor"
require "./processors/hash_processor"
require "./processors/mime_processor"
require "./processors/taken_at_processor"
require "./processors/extension_processor"

# Information about real file on disk
struct Scanner::FullCache::RealFile::Entity
  @taken_at : Time?
  @taken_at_missing : Bool?
  @valid = true

  def initialize(
    path : String | Path,
    @size : Int64?,
    @modification_time : Time?,
    @is_directory : Bool?,
    @hash : String?,
    @mime_type : String?,
    @taken_at : Time?,
    @taken_at_missing : Bool?
  )
    @path = Path.new(path)
  end

  getter :path, :size

  def initialize_basics
    size
    modification_time
  end

  def valid
    return false if size < SMALLEST_IMPORTANT_FILE
  end

  def basename
    return @path.basename
  end

  def file_extension
    return Processors::ExtensionProcessor.extension_for_path(@path)
  end

  def modification_time
    refresh_basic_info if @modification_time.nil?
    return @modification_time
  end

  def is_directory
    refresh_basic_info if @is_directory.nil?
    return @is_directory
  end

  private def refresh_basic_info
    basic_info = Processors::BasicProcessor.basic_data_for(@path)
    @modification_time = basic_info[:modification_time].as(Time)
    @is_directory = basic_info[:is_directory].as(Bool)
  end

  def size
    if @size.nil?
      @size = Processors::SizeProcessor.size_for(@path)
    end
    return @size.not_nil!
  end

  def hash
    if @hash.nil? || @hash == ""
      if size == 0
        # there is no point in calculating hash for empty files
        # some files are processed like they would be empty but they aren't
        @hash = "N/A"
      else
        @hash = Processors::HashProcessor.hash_for_path(@path).as(String)
      end
    end

    return @hash
  end

  def mime_type
    if @mime_type.nil? || @mime_type == ""
      @mime_type = Processors::MimeProcessor.mime_for_path(@path).as(String)
    end

    return @mime_type
  end

  def taken_at
    return nil if @taken_at_missing
    return @taken_at if @taken_at

    refresh_taken_at_if_needed

    return @taken_at
  end

  def taken_at_missing
    return nil if @taken_at
    return @taken_at_missing if @taken_at_missing

    refresh_taken_at_if_needed

    return @taken_at_missing
  end

  private def refresh_taken_at_if_needed
    if @taken_at.nil?
      ta = Processors::TakenAtProcessor.taken_at_for_path(@path)
      if ta.nil?
        # puts "#{@path} - taken_at missing"
        @taken_at_missing = true
        @taken_at = nil
      else
        @taken_at_missing = nil
        @taken_at = ta
      end
    end
  end
end
