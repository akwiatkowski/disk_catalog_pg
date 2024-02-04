h1== "Search for #{params[:query]}"
h2== "found #{count} files"

.table-responsive
  table.table.table-striped
    thead
      tr
        th Id
        th Disk
        th Path
        th Size
    tbody
    - files.each do |file_record|
      tr
        == render(partial: "_file_record.slang")
