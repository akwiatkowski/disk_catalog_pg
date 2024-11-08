require "../../config/application"
require "../../src/services/processors/generate_node_paths"

# disable sql logs
::Log.setup_from_env(default_level: :none)

populator = GenerateNodePaths.new
populator.all_missing
