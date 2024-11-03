class MimePopulator
  def initialize
  end

  def populate_for_node_file(node_file : NodeFile)
    # if disk is not mounted - ignore
    return unless File.exists?(node_file.file_path.to_s)

    meta_file = node_file.meta_file

    # do not overwrite
    return unless meta_file.mime_type_id.nil?

    mime_string = self.class.mime_type_for_file(node_file.file_path)

    mime_instance = MimeType.find_by(name: mime_string)
    if mime_instance.nil?
      mime_instance = MimeType.create(name: mime_string)
    end

    meta_file.mime_type_id = mime_instance.id
    meta_file.save

    puts "NF #{node_file.id}, MF #{meta_file.id} set mime #{mime_instance.id} = #{mime_instance.name}"
  end

  def self.mime_type_for_file(file_path)
    mime_command = "file --mime-type \"#{file_path}\""
    mime_result = `#{mime_command}`
    mime_string = mime_result.gsub(/[^:]+: /, "").strip
    return
  end
end
