class Scanner::BatchInsert
  # https://docs.amberframework.org/granite/docs/imports

  DEBUG_PUTS = false

  def initialize(
    @disk : Disk,
    @calculate_entities_hash : CalculateEntitiesHash,
    @batch_size : Int32
  )
    @index = 0
    @to_index = @index + @batch_size
    @max_index = 0 # temporary

    @mime_types = Hash(String, Int64).new
  end

  def make_it_so
    @max_index = file_entities.size.as(Int32)

    puts "* #{Time.lh}: start saving to DB #{file_entities.size} entities"
    iterate_batches
  end

  def file_entities
    return @calculate_entities_hash.file_entities
  end

  def mime_type_id_for_file_entry(file_entry : FileEntity)
    return mime_type_id_for_name(file_entry.mime_type)
  end

  def mime_type_id_for_name(mime_type_string : String)
    unless @mime_types[mime_type_string]?
      if MimeType.where(name: mime_type_string).exists?
        # preload and set
        @mime_types[mime_type_string] = MimeType.find_by!(name: mime_type_string).id.not_nil!
      else
        # need to create
        mime_type = MimeType.create(name: mime_type_string)
        @mime_types[mime_type_string] = mime_type.id.not_nil!
      end
    end

    return @mime_types[mime_type_string]
  end

  def iterate_batches
    while @index < @max_index
      batch = file_entities[@index...@to_index]
      puts "↑ #{Time.lh}: save batch from #{@index} to #{@to_index}, #{batch.size} entries" if DEBUG_PUTS

      save_meta_file_batch(batch)
      save_node_file_batch(batch)

      @index += @batch_size
      @to_index = @index + @batch_size
    end
  end

  def save_meta_file_batch(batch)
    t = Time.local

    meta_files = Array(MetaFile).new

    batch.each do |file_entity|
      meta_files << MetaFile.new(
        hash: file_entity.hash,
        size: file_entity.size,
        modification_time: file_entity.modification_time,
        mime_type_id: mime_type_id_for_file_entry(file_entity)
      )
    end

    MetaFile.import(meta_files, ignore_on_duplicate: true)

    puts "+ #{Time.lh}: imported #{meta_files.size} MetaFile instances, index #{@index}/#{@max_index}, taking #{(Time.local - t).milliseconds / 1000.0} s"
  end

  def save_node_file_batch(batch)
    t = Time.local
    node_files = Array(NodeFile).new

    batch.each do |file_entity|
      meta_file = MetaFile.find_by!(size: file_entity.size, hash: file_entity.hash)

      node_files << NodeFile.new(
        meta_file_id: meta_file.id,
        file_path: file_entity.path.to_s,
        disk_id: @disk.id,
        basename: file_entity.basename,
        file_extension: file_entity.file_extension
      )
    end

    NodeFile.import(node_files, ignore_on_duplicate: true)

    puts "+ #{Time.lh}: imported #{node_files.size} NodeFile instances, index #{@index}/#{@max_index}, taking #{(Time.local - t).milliseconds / 1000.0} s"
  end
end
