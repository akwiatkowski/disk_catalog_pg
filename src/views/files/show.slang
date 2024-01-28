h1
  = "file: "
  = file.basename

h2
  = "size: "
  = file.meta_file.size_human

h3
  = "disk: "
  = file.disk.name

- if duplications.empty?
  p= "no duplications"
- else
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Id
          th Disk
          th Path
      tbody
        - duplications.each do |duplications|
          tr
            td== link_to( duplications.id.to_s , "/files/#{duplications.id}", class: "btn btn-light btn-sm")
            td== duplications.disk.name
            td== duplications.file_path
