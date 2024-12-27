class FullCache::Scanner::Processors::Basic
  @modification_time : Time?
  @is_directory : Bool?

  def initialize(@file_path : String)
  end

  def call
    return {
      modification_time: modification_time,
      is_directory:      is_directory,
    }
  end

  def modification_time : Time
    get_data
    return @modification_time.not_nil!
  end

  def is_directory : Bool
    get_data
    return @is_directory.not_nil!
  end

  private def get_data
    return if @modification_time && @is_directory != nil

    Lg.thrivial(
      place: self.class,
      message: "basic info",
      path: @file_path
    ) do
      info = File.info(@file_path)

      @modification_time = info.modification_time.as(Time)
      @is_directory = info.directory?.as(Bool)
    end
  end
end
