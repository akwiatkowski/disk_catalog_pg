class Scanner::CacheToDb::DbCache::MimeTypeCache
  def initialize(@disk : Disk)
    @cache = Hash(String, MimeType).new
  end

  def instance_for(mime_type_string)
    if @cache[mime_type_string]?.nil?
      instance = find_or_create_for(mime_type_string).not_nil!
      @cache[mime_type_string] = instance

      puts "MimeType #{mime_type_string} - #{instance.id}"
    end

    return @cache[mime_type_string]
  end

  def find_or_create_for(mime_type_string)
    if MimeType.where(name: mime_type_string).exists?
      return MimeType.find_by(name: mime_type_string)
    else
      return MimeType.create(name: mime_type_string)
    end
  end
end
