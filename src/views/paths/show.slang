h1 Path

- if child_paths.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          td Dir id
          th Subdirectories
          th Size
      tbody
        - child_paths.each do |child_path|
          tr
            td== link_to( child_path.id.to_s , "/paths/#{child_path.id}", class: "btn btn-light btn-sm")
            td== child_path.basename || "N/A"
            td== SizeTools.to_human(child_path.size)

- if files.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          th File id
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
