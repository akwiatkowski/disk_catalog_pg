class Move::TagMoveScript
  def initialize(tag : Tag)
    @tag = tag
    @script_per_disk = Hash(Int64, String).new
  end

  def paths
    NodePath.where(move_tag_id: @tag.id)
  end

  def make_it_so
    paths.each do |path|
      @script_per_disk[path.disk.id.not_nil!] ||= ""
      @script_per_disk[path.disk.id.not_nil!] += "# path=#{path.id} \n"
    end

    return String.build do |s|
      @script_per_disk.keys.each do |disk_id|
        s << "# disk: #{disk_id} \n"
        s << @script_per_disk[disk_id]
      end
    end
  end
end
