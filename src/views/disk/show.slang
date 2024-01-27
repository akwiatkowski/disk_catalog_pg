h1 Show Disk

.table-responsive
  table.table.table-striped
    thead
      tr
        th Path
        th Size
        th Actions
    tbody
      - paths.each do |path|
        tr
          td = path.basename
          td
            span


p = disk.name
p = disk.path
p = disk.size
p
  == link_to("Back", "/disks", class: "btn btn-light btn-sm")
