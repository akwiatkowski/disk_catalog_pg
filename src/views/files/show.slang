h1
  = "file: "
  = file.basename

h4
  = "size: "
  = file.meta_file.size_human

h4
  = "disk: "
  = file.disk.name

hr

h3= "This file:"

.table-responsive
  table.table.table-striped
    thead
      tr
        th Id
        th Disk
        th Path
    tbody
      tr
        - file_record = file
        == render(partial: "_file_record.slang")

h3= "Duplications:"

- if duplications.empty?
  p= "there is no duplications"
- else
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Id
          th Disk
          th Path
      tbody
        - duplications.each do |duplications|
          tr
            - file_record = duplications
            == render(partial: "_file_record.slang")
