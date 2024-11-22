require "../entity"
require "../../real_file/factories/from_file"

class Scanner::FullCache::Unit::Factories::FromFile
  def initialize(path : Path | String)
    @path = Path.new(path)
  end

  def call
    file_entity = ::Scanner::FullCache::RealFile::Factories::FromFile.new(
      path: @path
    ).call

    instance = Entity.new(
      cache_time: Time.local,
      hash: file_entity.hash.not_nil!,
      size: file_entity.size.not_nil!.to_i64,
      modification_time: file_entity.modification_time.not_nil!,
      mime_type: file_entity.mime_type.not_nil!,
      is_directory: file_entity.is_directory.not_nil!,
      taken_at: file_entity.taken_at,
      taken_at_missing: file_entity.taken_at_missing
    )
    return instance
  end
end
