# File-like entity used in full cache container
# Path is not included here becase this is used in serialization
# {path: unit, path: unit}
struct FullCache::Models::Unit
  include YAML::Serializable

  @hash : String?
  @size : Int64?
  @cache_time : Time?
  @modification_time : Time?
  @mime_type : String?
  @is_directory : Bool?
  @taken_at : Time?
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
end
