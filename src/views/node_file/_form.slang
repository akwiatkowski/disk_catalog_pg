- if node_file.errors
  ul.errors
    - node_file.errors.each do |error|
      li = error.to_s

== form(action: "/node_files/#{node_file.id.to_s}", method: node_file.id ? :patch : :post) do
  == csrf_tag
  .form-group
    == label(:meta_file)
    == select_field(name: "meta_file_id", collection: MetaFile.all.map{|meta_file| [meta_file.id, meta_file.id]}, selected: node_file.meta_file_id, class: "form-control")
  .form-group
    == label(:disk)
    == select_field(name: "disk_id", collection: Disk.all.map{|disk| [disk.id, disk.id]}, selected: node_file.disk_id, class: "form-control")
  .form-group
    == text_field(name: "file_path", value: node_file.file_path, placeholder: "File_path", class: "form-control")
  == submit("Submit", class: "btn btn-success btn-sm")
  == link_to("Back", "/node_files", class: "btn btn-light btn-sm")
