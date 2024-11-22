require "../entity"

# missing data can be fetched from real file
class Scanner::FullCache::RealFile::Factories::FromFile
  def initialize(path : Path | String)
    @path = Path.new(path)
  end

  def call
    instance = Entity.new(
      path: @path,
      size: nil,
      modification_time: nil,
      is_directory: nil,
      hash: nil,
      mime_type: nil,
      taken_at: nil,
      taken_at_missing: nil
    )

    return instance
  end
end
