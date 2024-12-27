require "../entity"

# missing data can be fetched from real file
class Scanner::FullCache::RealFile::Factories::FromFile
  def initialize(path : Path | String)
    @t = Time.local.to_unix_ns
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

    # TODO: add processors usage here

    return instance
  end
end
