h1
  == "Search"
  - if query
    == " for #{params[:query]}"
    h2== "found #{count} files"

== form(action: "/files/search", method: :get) do
  == csrf_tag
  .form-group
    == text_field(name: "query", value: params[:query]?, placeholder: "Query", class: "form-control")
  == submit("Search", class: "btn btn-success btn-sm")

- if query
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Id
          th Disk
          th Path
          th Name
          th Size
      tbody
      - files.each do |file_record|
        tr
          == render(partial: "_file_record.slang")
