require "../config/application"
require "../src/services/mime_populator"

# disable sql logs
# ::Log.setup_from_env(default_level: :none)

populator = MimePopulator.new

# (820637...1_000_000).each do |node_file_id|
node_file = NodeFile.find!(1351749)
# node_file = NodeFile.find_by(id: node_file_id)
# next if node_file.nil?

# puts node_file.inspect
populator.populate_for_node_file(node_file.not_nil!)
# end
