h1 Node paths which needs duplication
h2
  == "count:"
  == count

.table-responsive
  table.table.table-striped
    thead
      tr
        th
        th Id
        th Name
        th Size
    tbody
      - i = 0
      - nps.each do |node_path|
        tr
          td== i += 1
          td== link_to( node_path.id.to_s , "/paths/#{node_path.id}", class: "btn btn-light btn-sm")
          td== node_path.basename.to_s
          td== SizeTools.to_human(node_path.size)
