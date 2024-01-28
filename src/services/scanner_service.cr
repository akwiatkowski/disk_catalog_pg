require "./file_entity"
require "./path_populator"
require "./mime_populator"

class ScannerService
  SHOW_PROGRESS_EVERY     =     100
  MIN_PROCESSED_FILE_SIZE = 500_000

  def initialize(
    @disk : Disk,
    @path_enabled = false,
    @mime_enaled = false
  )
    @path = Path.new(@disk.path.not_nil!)
    @name = @disk.name.not_nil!.as(String)

    @proper_size_count = 0
    @lower_size_count = 0

    @path_populator = PathPopulator.new
    @mime_populator = MimePopulator.new

    # used for calculation of total time cost
    @time_costs = Array(Int32).new
  end

  getter :path, :name

  def scan
    found = Dir[
      scan_pattern,
      follow_symlinks: false,
    ]

    count = found.size
    found.each_with_index do |found_path, i|
      if i % SHOW_PROGRESS_EVERY == 0
        percentage = ((100.0 * i.to_f) / count.to_f).round.to_i
        to_go = count - i

        predicted_time_cost_string = ""
        if @time_costs.size > 0
          average_time_cost = @time_costs.sum.to_f / @time_costs.size.to_f
          predicted_time_cost = (to_go.to_f * average_time_cost.to_f / 1_000_000.0).round.to_i

          predicted_time_cost_string = ", predicted time cost #{predicted_time_cost}s"
        end

        puts ". #{i}/#{count}, proper size count #{@proper_size_count}, lower size count #{@lower_size_count}, #{percentage}%#{predicted_time_cost_string}"
      end
      append(Path.new(found_path))
    end

    @disk.save!
  end

  def scan_pattern
    File.join([@path, "**/*"])
  end

  def append(found_path : Path)
    start_time = Time.local

    entity = FileEntity.new(path: found_path)
    return if entity.is_directory

    if entity.size < MIN_PROCESSED_FILE_SIZE
      @lower_size_count += 1
      return
    end

    @proper_size_count += 1

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
      @path_populator.populate_for_node_file(node_file) if @path_enabled
      @mime_populator.populate_for_node_file(node_file) if @mime_enaled
    end

    # append time cost to gradually calculate total time cost
    end_time = Time.local
    @time_costs << (end_time - start_time).microseconds

    node_file
  end
end
