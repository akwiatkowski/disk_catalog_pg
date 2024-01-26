.row
  .col-sm-11
    h2 Meta Files
  .col-sm-1
    a.btn.btn-success.btn-sm href="/meta_files/new" New
.table-responsive
  table.table.table-striped
    thead
      tr
        th Hash
        th Size
        th Modification_time
        th Actions
    tbody
      - meta_files.each do |meta_file|
        tr
          td = meta_file.hash
          td = meta_file.size
          td = meta_file.modification_time
          td
            span
              == link_to("Show", "/meta_files/#{meta_file.id}", class: "btn btn-info btn-sm")
              == link_to("Edit", "/meta_files/#{meta_file.id}/edit", class: "btn btn-success btn-sm")
              == link_to("Delete", "/meta_files/#{ meta_file.id }?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
