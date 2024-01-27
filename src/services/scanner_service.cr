require "./file_entity"

class ScannerService
  def initialize(
    @disk : Disk
  )
    @path = Path.new(@disk.path.not_nil!)
    @name = @disk.name.not_nil!.as(String)

    @done = 0
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

    # node_exists = NodeFile.where(
    #   "file_path = ? and disk_id = #{@disk.id} and meta_file_id = #{meta_file_id}",
    #   entity.path.to_s
    # ).exists?

    node_exists = NodeFile.where(
      file_path: entity.path.to_s,
      disk_id: @disk.id,
      meta_file_id: meta_file_id
    ).exists?

    if node_exists
      # do nothing
    else
      node_file = NodeFile.create(disk_id: @disk.id, meta_file_id: meta_file.not_nil!.id, file_path: entity.path.to_s)
    end
  end
end
