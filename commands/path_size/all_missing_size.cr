require "../../config/application"
require "../../src/services/processors/generate_node_path_size"

# disable sql logs
::Log.setup_from_env(default_level: :none)

service = Processors::GenerateNodePathSize.new

node_paths = NodePath.where(size: nil).each do |node_path|
  service.recalculate_node_path_size(node_path)
end
