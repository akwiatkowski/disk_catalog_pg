class Scanner::FullCache::RealFile::Processors::TakenAtProcessor
  LOCAL_LOCATION = Time::Location.load("Europe/Warsaw")

  EXTS_FOR_TAKEN_AT = [
    "jpg", "jpeg", "arw", "pef", "dng", "orf", "ori",
    "ari", "crw", "gpr", "nef", "nrw", "raf",
  ]

  def self.valid_extension_for_taken_at?(path)
    extension = Processors::ExtensionProcessor.extension_for_path(path)
    return EXTS_FOR_TAKEN_AT.includes?(extension)
  end

  def self.taken_at_for_path(path, location = LOCAL_LOCATION)
    return nil unless valid_extension_for_taken_at?(path)

    return taken_at_for_path!(path, location)
  end

  def self.taken_at_for_path!(path, location = LOCAL_LOCATION)
    command = "exiftool -T -DateTimeOriginal \"#{path}\""
    result = `#{command}` # 2019:10:12 20:00:45
    begin
      return taken_at = Time.parse(
        result,
        "%Y:%m:%d %H:%M:%S",
        location
      )
    rescue Time::Format::Error
      # a lot of file contain tiff like a thumbnail but we don't want
      # puts "Time::Format::Error - #{result} @ #{@path}"
    rescue ArgumentError
      # lets ignore this
    end
  end
end
