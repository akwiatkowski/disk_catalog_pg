td== link_to( file_record.id.to_s , "/files/#{file_record.id}", class: "btn btn-light btn-sm")
td== link_to( file_record.disk_name.to_s , "/disks/#{file_record.disk_id}", class: "btn btn-light btn-sm")
td
  - if file_record.node_path_id
    == link_to( file_record.node_path_basename.to_s , "/paths/#{file_record.node_path_id}", class: "btn btn-light btn-sm")
td== file_record.basename.to_s
td== SizeTools.to_human(file_record.size)
