.row
  .col-sm-11
    h2 Tags
  - if false
    .col-sm-1
      a.btn.btn-success.btn-sm href="/tags/new" New

.table-responsive
  table.table.table-striped
    thead
      tr
        th Name
        th Desc
        th Actions
    tbody
      - tags.each do |tag|
        tr
          td = tag.name
          td = tag.description
          td
            span
              == link_to("Show", "/tags/#{tag.id}", class: "btn btn-info btn-sm")
