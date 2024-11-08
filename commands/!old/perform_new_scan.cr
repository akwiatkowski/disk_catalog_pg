require "yaml"

require "../config/application"
require "../src/services/scanner/main"

# disable sql logs
::Log.setup_from_env(default_level: :none)

# disk = Disk.find_by(name: "test")
# disk = Disk.find_by(name: "disk G")
# disk = Disk.find_by(name: "disk H")
disk = Disk.find_by(name: "disk I")

service = Scanner::Main.new(
  disk: disk.not_nil!,
  filter_already_added_to_db: true
)
service.make_it_so

puts service.time_costs.to_yaml
