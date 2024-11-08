require "../../config/application"
require "../../src/services/processors/tag_storage"

# disable sql logs
::Log.setup_from_env(default_level: :none)

tag = Tag.find_by!(name: "raw")

service = TagStorage.new(raw_tag: tag)
service.make_it_so
