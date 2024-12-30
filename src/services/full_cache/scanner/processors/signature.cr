require "digest/md5"

class FullCache::Scanner::Processors::Signature
  @hash : String?

  def initialize(
    @file_path : String,
    @lg : Ui::Lg
  )
  end

  def call
    get_data

    return {
      hash: hash,
    }
  end

  def hash : String
    get_data
    return @hash.not_nil!
  end

  private def get_data
    return if @hash

    @lg.info(
      place: self.class,
      message: "hash signature info",
      path: @file_path
    ) do
      @hash = hash_for_path_crystal
      # @hash = hash_for_path_command
    end
  end

  private def hash_for_path_command
    command = "md5sum \"#{@file_path}\""
    result = `#{command}`
    hash = result.split(/\s/)[0]
    return hash
  end

  private def hash_for_path_crystal
    return Digest::MD5.new.file(@file_path).hexfinal
  end
end
