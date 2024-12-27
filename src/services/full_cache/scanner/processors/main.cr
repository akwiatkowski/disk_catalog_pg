require "./basic"
require "./size"
require "./signature"
require "./mime"
require "./taken_at"

require "../../factories/unit_factory"

class FullCache::Scanner::Processors::Main
  # file on disk was modified
  # some parts need to be updated
  @file_modified : Bool?
  # at leas one attr was changed - need to update in cache/container
  @was_changed : Bool?

  getter :was_changed

  def initialize(
    @file_path : String,
    @existing_unit : Models::Unit?
  )
    @basic = Basic.new(file_path: @file_path)
    @size = Size.new(file_path: @file_path)
    @signature = Signature.new(file_path: @file_path)
    @mime = Mime.new(file_path: @file_path)
    @taken_at = TakenAt.new(file_path: @file_path)
  end

  # create new Unit with all fields filled accordingly
  def call
    # keep in mind this flag is true if we scan new file
    if file_modified?
      Lg.info(
        place: self.class,
        message: "file modified",
        path: @file_path
      )

      # if file_modified when need to update: hash, size, modification_time
      # mime_type, is_directory, taken_at, taken_at_missing can be copied

      # the fact we know file was modified we know now that
      # we need to change Unit in cache/Container
      @was_changed = true
      new_cache_time = Time.local

      new_modification_time = @basic.modification_time
      new_is_directory = @basic.is_directory
      new_size = @size.size
      new_hash = @signature.hash
      new_mime_type = @mime.mime_type
      new_taken_at = @taken_at.taken_at
      new_taken_at_missing = @taken_at.taken_at_missing
    else
      missing_keys = Array(String).new

      if @existing_unit
        old_unit = @existing_unit.not_nil!
      else
        old_unit = Factories::UnitFactory.blank
      end

      new_modification_time = old_unit.modification_time
      new_is_directory = old_unit.is_directory
      new_size = old_unit.size
      new_hash = old_unit.hash
      new_cache_time = old_unit.cache_time
      new_mime_type = old_unit.mime_type
      new_taken_at = old_unit.taken_at
      new_taken_at_missing = old_unit.taken_at_missing

      # check if something is missing
      if new_modification_time.nil?
        Lg.debug(
          place: self.class,
          message: "missing modification_time",
          path: @file_path
        )
        new_modification_time = @basic.modification_time
        @was_changed = true
        missing_keys << "modification_time"
      end

      if new_is_directory.nil?
        Lg.debug(
          place: self.class,
          message: "missing is_directory",
          path: @file_path
        )
        new_is_directory = @basic.is_directory
        @was_changed = true
        missing_keys << "is_directory"
      end

      if new_size.nil?
        Lg.debug(
          place: self.class,
          message: "missing size",
          path: @file_path
        )
        new_size = @size.size
        @was_changed = true
        missing_keys << "size"
      end

      if new_hash.nil?
        Lg.debug(
          place: self.class,
          message: "missing hash",
          path: @file_path
        )
        new_hash = @signature.hash
        @was_changed = true
        missing_keys << "hash"
      end

      if new_mime_type.nil?
        Lg.debug(
          place: self.class,
          message: "missing mime_type",
          path: @file_path
        )
        new_mime_type = @mime.mime_type
        @was_changed = true
        missing_keys << "mime_type"
      end

      if @taken_at.valid_extenstion?
        if new_taken_at.nil? && new_taken_at_missing.nil?
          Lg.debug(
            place: self.class,
            message: "missing taken_at",
            path: @file_path
          )
          new_taken_at = @taken_at.taken_at
          new_taken_at_missing = @taken_at.taken_at_missing
          @was_changed = true
          missing_keys << "taken_at"
        end
      end

      if missing_keys.size > 0
        Lg.info(
          place: self.class,
          message: "fields missed: #{missing_keys.sort.join(",")}",
          path: @file_path
        )
      end
    end

    if @was_changed
      new_cache_time = Time.local

      return Models::Unit.new(
        hash: new_hash,
        size: new_size,
        cache_time: new_cache_time,
        modification_time: new_modification_time,
        mime_type: new_mime_type,
        is_directory: new_is_directory,
        taken_at: new_taken_at,
        taken_at_missing: new_taken_at_missing
      )
    end

    return nil
  end

  # even if file was not file_modified it can miss important data like
  # hash or taken_at. file_modified means we don't need to update fields like
  # hash and modification_time.
  def file_modified?
    if @file_modified.nil?
      if @existing_unit.nil? ||
         @basic.modification_time != @existing_unit.not_nil!.modification_time ||
         @size.size != @existing_unit.not_nil!.size
        @file_modified = true

        Lg.info(
          place: self.class,
          message: "file was changed from version in cache",
          path: @file_path
        )
      end

      @file_modified = false
    end

    return @file_modified
  end
end
