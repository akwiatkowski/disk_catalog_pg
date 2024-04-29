h1== tag.name

- summed_size = 0_i64

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
          th D.factor
          th Actions
      tbody
        - paths.each do |path|
          - summed_size += path.size.not_nil!.to_i64
          tr
            td== link_to( path.id.to_s , "/paths/#{path.id}", class: "btn btn-light btn-sm")
            td== link_to( path.disk.name.to_s , "/disks/#{path.disk_id}", class: "btn btn-light btn-sm")
            td== link_to( path.basename || "N/A" , "/paths/#{path.id}", class: "btn btn-light btn-sm")
            td== link_to( path.move_tag.name , "/tags/#{path.move_tag_id}", class: "btn btn-light btn-sm")
            td== SizeTools.to_human(path.size)
            td== path.materialized_duplication_factor
            td== link_to( "Edit" , "/paths/#{path.id}/edit", class: "btn btn-light btn-sm")

p
  Summed size
  strong== SizeTools.to_human(summed_size)

pre== service.make_it_so
