require "../config/application"
require "../src/services/mime_populator"

# disable sql logs
::Log.setup_from_env(default_level: :none)

populator = MimePopulator.new

JoinedFile.where(disk_name: "disk G", mime_type: nil).each do |joined_file|
  node_file = NodeFile.find!(joined_file.not_nil!.id)
  populator.populate_for_node_file(node_file.not_nil!)
end
