h1 Show Node File
p = node_file.meta_file.id
p = node_file.disk.id
p = node_file.file_path
p
  == link_to("Back", "/node_files", class: "btn btn-light btn-sm")
  == link_to("Edit", "/node_files/#{node_file.id}/edit", class: "btn btn-success btn-sm")
  == link_to("Delete", "/node_files/#{node_file.id}?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
