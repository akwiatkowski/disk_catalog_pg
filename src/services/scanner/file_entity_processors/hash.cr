require "digest/md5"

# TODO: convert to class methods? I'm pretty sure this module won't be used
# in.
module Scanner::FileEntityProcessors::Hash
  def hash_for_path(path)
    # crystal is a bit faster
    hash = hash_for_path_crystal(path)
    # hash = hash_for_path_command(path)
    return hash
  end

  def hash_for_path_command(path)
    command = "md5sum \"#{path}\""
    result = `#{command}`
    hash = result.split(/\s/)[0]
    return hash
  end

  def hash_for_path_crystal(path)
    return Digest::MD5.new.file(path).hexfinal
  end
end
