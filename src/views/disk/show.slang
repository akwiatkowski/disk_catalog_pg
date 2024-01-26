h1 Show Disk
p = disk.name
p = disk.path
p = disk.size
p
  == link_to("Back", "/disks", class: "btn btn-light btn-sm")
  == link_to("Edit", "/disks/#{disk.id}/edit", class: "btn btn-success btn-sm")
  == link_to("Delete", "/disks/#{disk.id}?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
