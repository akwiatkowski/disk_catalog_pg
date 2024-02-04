require "../../config/application"
require "../../src/services/path_populator"

# disable sql logs
::Log.setup_from_env(default_level: :none)

i = 0_i64
duplications = 0_i64

NodePath.where(materialized_duplication_factor: nil).each do |node_path|
  node_path.update_duplication_factor!

  i += 1
  if (i % 100) == 0
    puts "#{i} NP#update_duplication_factor"
  end
end
