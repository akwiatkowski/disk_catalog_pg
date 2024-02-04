require "../../config/application"
require "../../src/services/path_populator"

# disable sql logs
::Log.setup_from_env(default_level: :none)

i = 0_i64
duplications = 0_i64

NodeFile.where(materialized_duplication_count: nil).each do |node_file|
  puts "start" if i == 0

  duplication_for_nf = NodeFile.where(meta_file_id: node_file.meta_file_id).count.to_s.to_i
  duplications += duplication_for_nf

  node_file.materialized_duplication_count = duplication_for_nf
  node_file.save!

  i += 1
  if (i % 10_000) == 0
    puts "#{i} NF#materialized_duplication_count updated, factor #{duplications.to_f / i.to_f}"
  end
end
