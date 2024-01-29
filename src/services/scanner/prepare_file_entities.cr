require "./file_entity"

class Scanner::PrepareFileEntities
  def initialize(@pre_filter : PreFilter)
    @file_entities = Array(FileEntity).new
  end

  getter :file_entities

  def make_it_so
    @pre_filter.file_paths.each do |file_path|
      @file_entities << FileEntity.new(path: Path.new(file_path))
    end

    puts "generated #{@file_entities.size} file entities (w/o hash)"
  end
end
