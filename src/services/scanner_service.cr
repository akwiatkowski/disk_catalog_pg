require "./file_entity"
require "./path_populator"

class ScannerService
  def initialize(
    @disk : Disk
  )
    @path = Path.new(@disk.path.not_nil!)
    @name = @disk.name.not_nil!.as(String)

    @done = 0

    @path_populator = PathPopulator.new
  end

  getter :path, :name

  def scan
    found = Dir[
      scan_pattern,
      follow_symlinks: false,
    ]

    found.each do |found_path|
      append(Path.new(found_path))
    end

    @disk.save!
  end

  def scan_pattern
    File.join([@path, "**/*"])
  end

  def append(found_path : Path)
    entity = FileEntity.new(path: found_path)
    return if entity.is_directory
    # TODO: move it to constant
    return if entity.size < 500_000

    @done += 1

    if @done % 1000 == 0
      puts "done #{@done}"
    end

    # do not overwrite
    return if NodeFile.where(
                file_path: entity.path.to_s,
                disk_id: @disk.id
              ).exists?

    # metafile
    if MetaFile.where(hash: entity.hash, size: entity.size).exists?
      meta_file = MetaFile.find_by(hash: entity.hash, size: entity.size)
    else
      meta_file = MetaFile.create(hash: entity.hash, size: entity.size, modification_time: entity.modification_time)
    end

    meta_file_id = meta_file.not_nil!.id

    node_exists = NodeFile.where(
      file_path: entity.path.to_s,
      disk_id: @disk.id,
      meta_file_id: meta_file_id
    ).exists?

    if node_exists
      # do nothing
    else
      node_file = NodeFile.create(disk_id: @disk.id, meta_file_id: meta_file.not_nil!.id, file_path: entity.path.to_s)
      @path_populator.populate_for_node_file(node_file)
    end

    node_file
  end
end
