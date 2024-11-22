require "../entity"
require "../../real_file/factories/from_file"

class Scanner::FullCache::Unit::Factories::Update
  def initialize(@unit : Unit::Entity, path : Path | String)
    @path = Path.new(path)
    @update_result = false
    @file_entity = ::Scanner::FullCache::RealFile::Factories::FromFile.new(
      path: @path
    ).call.as(RealFile::Entity)
  end

  getter :update_result

  def basic_params_changed?
    new_size != old_size || new_modification_time != old_modification_time
  end

  private def mark_update_result!
    @update_result = true
  end

  def new_size
    return @file_entity.size.not_nil!.to_i64
  end

  def old_size
    return @unit.size
  end

  def new_modification_time
    return @file_entity.modification_time.not_nil!
  end

  def old_modification_time
    return @unit.modification_time
  end

  def call
    new_hash = @unit.hash
    new_taken_at = @unit.taken_at
    new_taken_at_missing = @unit.taken_at_missing
    new_mime_type = @unit.mime_type
    new_is_directory = @unit.is_directory

    # when basic info was change we need to recalculate hash
    # this is time consuming
    if basic_params_changed?
      mark_update_result!

      new_hash = @file_entity.hash.not_nil!
    end

    # fill `taken_at_missing`
    if @unit.taken_at_missing.nil? && !@file_entity.taken_at_missing.nil?
      puts "file #{@path} taken_at not possible to get, marking as missing"

      mark_update_result!

      new_taken_at_missing = @file_entity.taken_at_missing
      new_taken_at = @file_entity.taken_at
    end

    # fill `taken_at`
    if !new_taken_at_missing && new_taken_at.nil?
      puts "file #{@path} taken_at was missing, updating to #{@file_entity.taken_at}"

      mark_update_result!

      new_taken_at = @file_entity.taken_at
      new_taken_at_missing = @file_entity.taken_at_missing
    end

    instance = Entity.new(
      cache_time: Time.local,
      hash: new_hash,
      size: new_size,
      modification_time: new_modification_time,
      mime_type: new_mime_type,
      is_directory: new_is_directory,
      taken_at: new_taken_at,
      taken_at_missing: new_taken_at_missing
    )

    return instance
  end
end
