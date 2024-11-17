require "./node_path_size_materializer"
require "./node_file_duplication_count_materializer"

class Materializers::Main
  def initialize(@disk : Disk)
    @node_path_size = NodePathSizeMaterializer.new(disk: @disk)
    @node_file_duplication_count_materializer = NodeFileDuplicationCountMaterializer.new(disk: @disk)
  end

  def make_it_so
    # TODO: whole idea is to calculate from scratch to overwrite
    # data generated on partial data
    # @node_path_size.make_it_so
    @node_file_duplication_count_materializer.make_it_so
  end
end
