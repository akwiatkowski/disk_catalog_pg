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
          th Files
      tbody
        - files.each do |file|
          tr
            td== link_to( (file.file_path || "...").to_s , "/files/#{file.id}", class: "btn btn-light btn-sm")

p = path.relative_path
p = path.disk.name
p = path.basename
