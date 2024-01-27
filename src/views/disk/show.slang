h1 Show Disk

.table-responsive
  table.table.table-striped
    thead
      tr
        th Path
    tbody
      - paths.each do |path|
        tr
          td== link_to( (path.basename || "/").to_s , "/paths/#{path.id}", class: "btn btn-light btn-sm")


p = disk.name
p = disk.path
p = disk.size
p
  == link_to("Back", "/disks", class: "btn btn-light btn-sm")
