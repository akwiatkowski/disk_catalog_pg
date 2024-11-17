require "yaml"

require "../../config/application"
require "../../src/services/materializers/main"

# disable sql logs
# ::Log.setup_from_env(default_level: :none)

if Disk.where(name: "disk A").exists?
  disk = Disk.find_by(name: "disk A")
else
  disk = Disk.create(
    path: "/media/olek/a_disk/",
    description: "disk A",
    name: "disk A",
    size: 4000,
  )
end

service = Materializers::Main.new(
  disk: disk.not_nil!
)
service.make_it_so
