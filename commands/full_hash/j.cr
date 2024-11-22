require "yaml"

require "../../config/application"
require "../../src/services/scanner/main"

# disable sql logs
::Log.setup_from_env(default_level: :none)

disk = Disk.find_by(name: "disk J")

service = Scanner::FullCache::Scanner.new(
  disk: disk.not_nil!,
)
service.make_it_so
