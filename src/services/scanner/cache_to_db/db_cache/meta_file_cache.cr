class Scanner::CacheToDb::DbCache::MetaFileCache
  def initialize(@disk : Disk)
    @cache = Hash(String, MimeType).new
  end

  def instance_for(
    hash : String,
    size : Int64,
    modification_time : Time,
    mime_type : MimeType
  )
    return find_or_create_for(
      hash: hash,
      size: size,
      modification_time: modification_time,
      mime_type: mime_type
    ).not_nil!
  end

  def find_or_create_for(
    hash : String,
    size : Int64,
    modification_time : Time,
    mime_type : MimeType
  )
    if MetaFile.where(hash: hash, size: size).exists?
      return MetaFile.find_by(hash: hash, size: size)
    else
      return MetaFile.create(
        hash: hash,
        size: size,
        modification_time: modification_time,
        mime_type: mime_type
      )
    end
  end
end
