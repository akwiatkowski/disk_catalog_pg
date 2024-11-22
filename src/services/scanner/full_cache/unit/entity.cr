# Structure which is being used on "full cache"
struct Scanner::FullCache::Unit::Entity
  include YAML::Serializable

  SMALLEST_IMPORTANT_FILE = 512

  @hash : String
  @size : Int64
  @cache_time : Time
  @modification_time : Time
  @mime_type : String
  @is_directory : Bool
  @taken_at : Time?
  # when file was processed and we don't want to process again
  @taken_at_missing : Bool?

  getter :hash, :size, :cache_time, :modification_time, :mime_type,
    :is_directory, :taken_at, :taken_at_missing

  def initialize(
    @hash,
    @size,
    @cache_time,
    @modification_time,
    @mime_type,
    @is_directory,
    @taken_at,
    @taken_at_missing
  )
  end

  def valid?
    return false if @size < SMALLEST_IMPORTANT_FILE
    return true
  end
end
