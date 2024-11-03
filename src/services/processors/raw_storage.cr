struct DestinationNodePath
  def initialize(@node_path)
  end
end

class TagStorage
  def initialize(@raw_tag : Tag)
  end

  def make_it_so
    @raw_tag.node_paths.each do |first_level_node|
      first_level_node.children_node_paths.each do |second_level_node|
        puts second_level_node.basename

        # TODO: add all raw directories, calculate how much it is stored
        # add files from multiple disks/paths if they are from same
        # raw directory (or date)
        #
        # check how much it's redundant
      end
    end
  end
end
