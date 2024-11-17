class Materializers::NodeFileDuplicationCountMaterializer
  def initialize(@disk : Disk)
  end

  def make_it_so
    NodeFile.where(disk_id: @disk.id).each do |node_file|
      # TODO: as always - there is a lot of space to optimize
      node_file.materialized_duplication_count = node_file.duplications.to_a.size
      # TODO: is it possible to update only one column?
      node_file.save!
    end
  end
end
