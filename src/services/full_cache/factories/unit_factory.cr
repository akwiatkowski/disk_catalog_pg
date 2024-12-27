require "../models/unit"

class FullCache::Factories::UnitFactory
  def self.blank
    return Models::Unit.new(
      hash: nil,
      size: nil,
      cache_time: Time.local,
      modification_time: nil,
      mime_type: nil,
      is_directory: nil,
      taken_at: nil,
      taken_at_missing: nil
    )
  end
end
