h1 Show Meta File
p = meta_file.hash
p = meta_file.size
p = meta_file.modification_time
p
  == link_to("Back", "/meta_files", class: "btn btn-light btn-sm")
  == link_to("Edit", "/meta_files/#{meta_file.id}/edit", class: "btn btn-success btn-sm")
  == link_to("Delete", "/meta_files/#{meta_file.id}?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
