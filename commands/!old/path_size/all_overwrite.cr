require "../../config/application"
require "../../src/services/processors/materialize_node_path_size"

# disable sql logs
::Log.setup_from_env(default_level: :none)

service = Processors::MaterializeNodePathSize.new
service.all_overwrite
