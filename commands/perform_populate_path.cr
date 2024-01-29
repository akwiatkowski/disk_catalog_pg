require "../config/application"
require "../src/services/path_populator"

# disable sql logs
::Log.setup_from_env(default_level: :none)

populator = PathPopulator.new

NodeFile.where(node_path_id: nil).each do |node_file|
  populator.populate_for_node_file(node_file.not_nil!)
end
