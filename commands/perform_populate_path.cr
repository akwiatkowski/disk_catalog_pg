require "../config/application"
require "../src/services/path_populator"

# disable sql logs
::Log.setup_from_env(default_level: :none)

populator = PathPopulator.new

(1...10_000).each do |node_file_id|
  node_file = NodeFile.find(node_file_id)
  populator.populate_for_node_file(node_file.not_nil!)
end
