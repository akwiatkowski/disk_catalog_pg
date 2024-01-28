h1 Path

- if child_paths.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Subdirectories
      tbody
        - child_paths.each do |child_path|
          tr
            td== link_to( (child_path.basename || "/").to_s , "/paths/#{child_path.id}", class: "btn btn-light btn-sm")

- if files.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Id
          th Path
          th Size
      tbody
        - files.each do |file|
          tr
            td== link_to( file.id.to_s , "/files/#{file.id}", class: "btn btn-light btn-sm")
            td== file.file_path
            td== file.meta_file.size_human

p = path.relative_path
p = path.disk.name
p = path.basename
