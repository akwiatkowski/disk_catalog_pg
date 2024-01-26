.row
  .col-sm-11
    h2 Node Files
  .col-sm-1
    a.btn.btn-success.btn-sm href="/node_files/new" New
.table-responsive
  table.table.table-striped
    thead
      tr
        th Meta_file
        th Disk
        th File_path
        th Actions
    tbody
      - node_files.each do |node_file|
        tr
          td = node_file.meta_file.id
          td = node_file.disk.id
          td = node_file.file_path
          td
            span
              == link_to("Show", "/node_files/#{node_file.id}", class: "btn btn-info btn-sm")
              == link_to("Edit", "/node_files/#{node_file.id}/edit", class: "btn btn-success btn-sm")
              == link_to("Delete", "/node_files/#{ node_file.id }?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
