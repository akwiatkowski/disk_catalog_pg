h1 Path
h2
  == "path: "
  == path.relative_path
h3
  == "disk: "
  == path.disk.name
- if path.tag_id
  h4
    == "tag: "
    == path.tag.name
- if path.parent_node_path_id
  h4
    == "parent: "
    == link_to( path.parent_node_path.relative_path || "N/A", "/paths/#{path.parent_node_path_id}", class: "btn btn-light btn-sm")


- if child_paths.exists?
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Dir id
          th Subdirectories
          th Tag
          th Size
          th Actions
      tbody
        - child_paths.each do |child_path|
          tr
            td== link_to( child_path.id.to_s , "/paths/#{child_path.id}", class: "btn btn-light btn-sm")
            td== link_to( child_path.basename || "N/A" , "/paths/#{child_path.id}", class: "btn btn-light btn-sm")
            td
              - if child_path.tag_id
                == link_to( child_path.tag.name , "/tags/#{child_path.tag_id}", class: "btn btn-light btn-sm")
              - else
                == "N/A"
            td== SizeTools.to_human(child_path.size)
            td== link_to( "Edit" , "/paths/#{child_path.id}/edit", class: "btn btn-light btn-sm")

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
            td== link_to( file.basename , "/files/#{file.id}", class: "btn btn-light btn-sm")
            td== file.meta_file.size_human

p = path.relative_path
p = path.disk.name
p = path.basename
