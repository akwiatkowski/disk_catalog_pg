h1== tag.name

- if paths.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Dir id
          th Disk
          th Subdirectory
          th Tag
          th Size
          th Actions
      tbody
        - paths.each do |path|
          tr
            td== link_to( path.id.to_s , "/paths/#{path.id}", class: "btn btn-light btn-sm")
            td== link_to( path.disk.name.to_s , "/disks/#{path.disk_id}", class: "btn btn-light btn-sm")
            td== link_to( path.basename || "N/A" , "/paths/#{path.id}", class: "btn btn-light btn-sm")
            td== link_to( path.tag.name , "/tags/#{path.tag_id}", class: "btn btn-light btn-sm")
            td== SizeTools.to_human(path.size)
            td== link_to( "Edit" , "/paths/#{path.id}/edit", class: "btn btn-light btn-sm")
