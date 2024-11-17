require "yaml"

require "../../config/application"
require "../../src/services/materializers/main"

# disable sql logs
# ::Log.setup_from_env(default_level: :none)

unless Disk.where(name: "zdj test").exists?
  Disk.create(
    name: "zdj test",
    description: "test",
    path: "/home/olek/Dokumenty/zdjecia/main/2024/2024-A/2024-01-09 - ziebice zima/",
    size: 1000
  )
end

disk = Disk.find_by(name: "zdj test")

service = Materializers::Main.new(
  disk: disk.not_nil!
)
service.make_it_so
