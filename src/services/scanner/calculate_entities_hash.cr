require "./file_entity"

class Scanner::CalculateEntitiesHash
  MIN_FILE_SIZE = 500_000

  def initialize(
    @prepare_file_entities : PrepareFileEntities,
    @batch_size : Int32 = 200
  )
    @file_entities = Array(FileEntity).new
  end

  getter :file_entities

  def make_it_so
    @file_entities = @prepare_file_entities.file_entities.select do |file_entity|
      file_entity.size >= MIN_FILE_SIZE
    end.as(Array(FileEntity))

    total_files_size = 0_i64
    @file_entities.each do |file_entity|
      total_files_size += file_entity.size
    end

    puts "start to generate hash for #{@file_entities.size} files (size > #{MIN_FILE_SIZE / 1024}kB), #{(total_files_size / (1024 ** 2)).round.to_i} MB"

    start_time = Time.local
    size_hashed_files_bytes = 0_i64

    @file_entities.each_with_index do |file_entity, i|
      file_entity.hash

      time_from_start = (Time.local - start_time).seconds.to_f
      next if time_from_start < 1.0

      size_hashed_files_bytes += file_entity.size
      hash_speed_bytes_per_second = size_hashed_files_bytes.to_f / (time_from_start)
      hash_speed_mega_bytes_per_second = (hash_speed_bytes_per_second / 1024.0) / 1024.0
      eta_time_in_seconds = (total_files_size.to_f - size_hashed_files_bytes.to_f) / hash_speed_bytes_per_second.to_f

      if ((i + 1) % @batch_size == 0)
        puts "... generated hash for #{i}/#{@file_entities.size} with speed of #{hash_speed_mega_bytes_per_second.to_i} MB/s, ETA #{eta_time_in_seconds.to_i} s"
      end
    end
  end
end
