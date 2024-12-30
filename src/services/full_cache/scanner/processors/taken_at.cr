class FullCache::Scanner::Processors::TakenAt
  LOCAL_LOCATION = Time::Location.load("Europe/Warsaw")

  EXTS_FOR_TAKEN_AT = [
    "jpg", "jpeg", "arw", "pef", "dng", "orf", "ori",
    "ari", "crw", "gpr", "nef", "nrw", "raf",
  ]

  @taken_at : Time?
  @taken_at_missing : Bool?

  def initialize(
    @file_path : String,
    @lg : Ui::Lg,
    @location = LOCAL_LOCATION
  )
    @extension = Path.new(@file_path).extension.gsub(/^\./, "").to_s.downcase
    @processed = false
  end

  def call
    get_data

    return {
      taken_at:         taken_at,
      taken_at_missing: taken_at_missing,
    }
  end

  def taken_at
    get_data
    return @taken_at
  end

  def taken_at_missing
    get_data
    return @taken_at_missing
  end

  def valid_extenstion?
    return EXTS_FOR_TAKEN_AT.includes?(@extension)
  end

  def self.extension_for_path(path)
    return
  end

  private def get_data
    return if @processed

    @lg.info(
      place: self.class,
      message: "taken_at info ",
      path: @file_path
    ) do
      return unless valid_extenstion?

      @taken_at = process_taken_at
      @taken_at_missing = true if @taken_at.nil?

      @lg.info(
        place: self.class,
        message: "taken_at=#{@taken_at}, taken_at_missing=#{@taken_at_missing}",
        path: @file_path
      )
    end

    @processed = true
  end

  def process_taken_at
    command = "exiftool -T -DateTimeOriginal \"#{@file_path}\""
    result = `#{command}` # 2019:10:12 20:00:45
    begin
      return Time.parse(
        result,
        "%Y:%m:%d %H:%M:%S",
        @location
      )
    rescue Time::Format::Error
      # a lot of file contain tiff like a thumbnail but we don't want
      # puts "Time::Format::Error - #{result} @ #{@path}"
    rescue ArgumentError
      # lets ignore this
    end
  end
end
