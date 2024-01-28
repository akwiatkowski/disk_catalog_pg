require "../config/application"
require "../src/services/scanner_service"

# disable sql logs
::Log.setup_from_env(default_level: :none)

disk = Disk.find_by(name: "disk H")
service = ScannerService.new(disk: disk.not_nil!)

puts "start scan"

service.scan
