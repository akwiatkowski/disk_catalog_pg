struct Scanner::FullCache::Unit
  include YAML::Serializable

  @hash : String
  @size : Int64
  @cache_time : Time
  @modification_time : Time
  @mime_type : String
  @is_directory : Bool

  getter :hash, :size, :cache_time, :modification_time, :mime_type, :is_directory

  def initialize(file_path : String)
    file_entity = ::Scanner::FileEntity.new(path: Path.new(file_path))

    @cache_time = Time.local

    @hash = file_entity.hash
    @size = file_entity.size.to_i64
    @modification_time = file_entity.modification_time
    @mime_type = file_entity.mime_type
    @is_directory = file_entity.is_directory
  end

  def update!(file_path : String)
    file_entity = ::Scanner::FileEntity.new(path: Path.new(file_path))

    @cache_time = Time.local

    new_size = file_entity.size.to_i64
    new_modification_time = file_entity.modification_time

    if @size != new_size || @modification_time != new_modification_time
      puts "file #{file_path} was modified"
      @hash = file_entity.hash
      @size = new_size
      @modification_time = new_modification_time
      return true
    end

    return false
  end
end
