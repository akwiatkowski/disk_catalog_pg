td== link_to( file_record.id.to_s , "/files/#{file_record.id}", class: "btn btn-light btn-sm")
td== link_to( file_record.disk.name.to_s , "/disks/#{file_record.disk.id}", class: "btn btn-light btn-sm")
td== file_record.file_path
td== SizeTools.to_human(file_record.meta_file.size)
