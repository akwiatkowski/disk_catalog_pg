require "../../config/application"
require "../../src/services/processors/materialize_duplication_factor"

# disable sql logs
::Log.setup_from_env(default_level: :none)

MaterializeDuplicationFactor.new.all_overwrite
