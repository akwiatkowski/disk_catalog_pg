require "../../config/application"
require "../../src/services/processors/materialize_duplication_count"

# disable sql logs
::Log.setup_from_env(default_level: :none)

MaterializeDuplicationCount.new.all_overwrite
