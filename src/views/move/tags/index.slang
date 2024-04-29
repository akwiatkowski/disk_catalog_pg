.row
  .col-sm-11
    h2 Move: Tags

.table-responsive
  table.table.table-striped
    thead
      tr
        th Name
        th Desc
        th Path count
        th Actions
    tbody
      - tags.each do |tag|
        - present = (tag.move_paths_count > 0)
        - if present
          tr
            td = tag.name
            td = tag.description
            td = tag.move_paths_count
            td
              span
              == link_to("Details", "/move/tags/#{tag.id}", class: "btn btn-info btn-sm")
