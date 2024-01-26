.row
  .col-sm-11
    h2 Disks
  .col-sm-1
    a.btn.btn-success.btn-sm href="/disks/new" New
.table-responsive
  table.table.table-striped
    thead
      tr
        th Name
        th Path
        th Size
        th Actions
    tbody
      - disks.each do |disk|
        tr
          td = disk.name
          td = disk.path
          td = disk.size
          td
            span
              == link_to("Show", "/disks/#{disk.id}", class: "btn btn-info btn-sm")
              == link_to("Edit", "/disks/#{disk.id}/edit", class: "btn btn-success btn-sm")
              == link_to("Scan", "/disks/#{disk.id}/scan", class: "btn btn-success btn-sm")              
              == link_to("Delete", "/disks/#{ disk.id }?_csrf=#{csrf_token}", "data-method": "delete", "data-confirm": "Are you sure?", class: "btn btn-danger btn-sm")
