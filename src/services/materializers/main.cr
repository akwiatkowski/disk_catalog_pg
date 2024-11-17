require "./node_path_size_materializer"

class Materializers::Main
  def initialize(@disk : Disk)
    @node_path_size = NodePathSizeMaterializer.new(disk: @disk)
  end

  def make_it_so
    @node_path_size.make_it_so
  end
end
