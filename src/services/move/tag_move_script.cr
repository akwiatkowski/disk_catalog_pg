class Move::TagMoveScript
  def initialize(tag : Tag)
    @tag = tag
    @script_per_disk = Hash(Int64, String).new
    @meta_file_ids = Array(Int64).new

    @sum_total = 0_i64
    @sum_uniq = 0_i64

    @debug = true
  end

  getter :debug

  private def paths
    NodePath.where(move_tag_id: @tag.id)
  end

  def make_it_so
    paths.each do |path|
      disk_id = path.disk.id.not_nil!
      move_file_scope = MoveFile.where(node_path_id: path.id)

      # TODO: files in subdirectories also
      # get all node_paths and filter using array of node_path_id

      if @script_per_disk[disk_id]?.nil?
        @script_per_disk[disk_id] = "# disk: #{path.disk.name} \n"
      end

      @script_per_disk[disk_id] += String.build do |s|
        s << "# path #{path.id}: #{path.relative_path} ; files_count: #{move_file_scope.count} \n"

        move_file_scope.each do |move_file|
          next if move_file.should_be_ignored

          if debug
            s << "# #{move_file.to_h.inspect} \n"
          end

          already_copied = @meta_file_ids.includes?(move_file.meta_file_id)
          if already_copied
            s << "# file #{move_file.file_path} has already been copied \n"

            @sum_total += move_file.file_size
          else
            s << "# file #{move_file.file_path} size #{SizeTools.to_human(move_file.file_size)} \n"
            s << "cp \"#{move_file.file_path}\" \"./#{move_file.move_relative_path}/#{move_file.file_basename}\" \n"
            @meta_file_ids << move_file.meta_file_id.not_nil!

            @sum_uniq += move_file.file_size
            @sum_total += move_file.file_size
          end
        end
      end
    end

    return String.build do |s|
      @script_per_disk.keys.each do |disk_id|
        s << @script_per_disk[disk_id]
        s << "\n\n"

        s << "# total: #{SizeTools.to_human(@sum_total)}, uniq #{SizeTools.to_human(@sum_uniq)}\n"
      end
    end
  end
end
