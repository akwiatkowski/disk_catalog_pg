require "digest/md5"

class Scanner::FullCache::RealFile::Processors::HashProcessor
  def self.hash_for_path(path)
    # crystal is a bit faster
    hash = hash_for_path_crystal(path)
    # hash = hash_for_path_command(path)
    return hash
  end

  def self.hash_for_path_command(path)
    command = "md5sum \"#{path}\""
    result = `#{command}`
    hash = result.split(/\s/)[0]
    return hash
  end

  def self.hash_for_path_crystal(path)
    return Digest::MD5.new.file(path).hexfinal
  end
end
