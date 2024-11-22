struct Scanner::FullCache::Unit
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

  # TODO: write better way of convertint Unit <-> FileEntity
  def initialize(file_path : String)
    file_entity = ::Scanner::FileEntity.new(path: Path.new(file_path))

    @cache_time = Time.local

    @hash = file_entity.hash
    @size = file_entity.size.to_i64
    @modification_time = file_entity.modification_time
    @mime_type = file_entity.mime_type
    @is_directory = file_entity.is_directory
    @taken_at = file_entity.taken_at
    # TODO: taken_at_missing is not working right now
    # test it on small directory
    @taken_at_missing = file_entity.taken_at_missing
  end

  # TODO: create service converting Unit <-> FileEntity
  # TODO: create service getting information about basic parameters (like a factory)
  # NOTE: time cost because of checking file size if file was not updated
  # maybe it would be possible to do a first run to ignore (only insert) and
  # second run when everything was added to ensure data is correct (only update)
  # third to remove missing files
  def update!(file_path : String)
    update_result = false
    file_entity = ::Scanner::FileEntity.new(
      path: Path.new(file_path)
    )

    @cache_time = Time.local

    new_size = file_entity.size.to_i64
    new_modification_time = file_entity.modification_time

    size_changed = (@size != new_size)
    modification_time_change = (@modification_time != new_modification_time)
    basic_params_changed = size_changed || modification_time_change

    # TODO: think of conditions to run update of unit/file/record to yaml cache
    # which fields are important?
    if basic_params_changed
      puts "file #{file_path} was modified"
      @hash = file_entity.hash
      @size = new_size
      @modification_time = new_modification_time
      # original photo taken at should not be modified
      # @taken_at = new_taken_at
      update_result = true
    end

    # fill `taken_at_missing`
    if @taken_at_missing.nil? && !file_entity.taken_at_missing.nil?
      puts "file #{file_path} taken_at not possible to get, marking as missing"
      @taken_at_missing = true
      update_result = true
    end

    # if we now taken_at is missing there is no point at checking again taken_at
    unless @taken_at_missing
      # fill `taken_at`
      # temporary added logic to overwrite UTC times to local
      if (@taken_at.nil? || @taken_at.not_nil!.utc?) && !file_entity.taken_at.nil?
        puts "file #{file_path} taken_at was missing, updating to #{file_entity.taken_at}"
        @taken_at = file_entity.taken_at.not_nil!
        update_result = true
      end
    end

    return update_result
  end

  def valid?
    return false if @size < SMALLEST_IMPORTANT_FILE
    return true
  end
end
