class Scanner::FullCache::RealFile::Processors::BasicProcessor
  def self.basic_data_for(path)
    info = File.info(path)

    modification_time = info.modification_time.as(Time)
    is_directory = info.directory?.as(Bool)

    return {
      modification_time: modification_time,
      is_directory:      is_directory,
    }
  end
end
