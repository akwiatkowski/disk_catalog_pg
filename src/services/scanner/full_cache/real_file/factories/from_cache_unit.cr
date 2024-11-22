require "../entity"

# missing data can be fetched from real file
class Scanner::FullCache::RealFile::Factories::FromFile
  def initialize(@path : Path, @cache_unit : Unit)
  end

  def call
    instance = Entity.new(
      path: @path,
      size: cache_unit.size,
      modification_time: cache_unit.modification_time,
      is_directory: cache_unit.is_directory,
      hash: cache_unit.hash,
      mime_type: cache_unit.mime_type,
      taken_at: cache_unit.taken_at,
      taken_at_missing: cache_unit.taken_at_missing
    )

    return instance
  end
end
