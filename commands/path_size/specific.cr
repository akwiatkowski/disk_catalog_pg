require "../../config/application"
require "../../src/services/processors/generate_node_path_size"

# disable sql logs
# ::Log.setup_from_env(default_level: :none)

service = Processors::GenerateNodePathSize.new

id = 1050
node_path = NodePath.find_by!(id: id)
service.recalculate_node_path_size(node_path)
