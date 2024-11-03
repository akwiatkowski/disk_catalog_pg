- if disk.errors
  ul.errors
    - disk.errors.each do |error|
      li = error.to_s

== form(action: "/disks/#{disk.id.to_s}", method: disk.id ? :patch : :post) do
  == csrf_tag
  .form-group
    == text_field(name: "name", value: disk.name, placeholder: "Name", class: "form-control")
  .form-group
    == text_field(name: "description", value: disk.description, placeholder: "Description", class: "form-control")
  .form-group
    == text_field(name: "path", value: disk.path, placeholder: "Path", class: "form-control")
  .form-group
    == text_field(name: "size", value: disk.size, placeholder: "Size (1000 means 1TB)", class: "form-control")
  == submit("Submit", class: "btn btn-success btn-sm")
  == link_to("Back", "/disks", class: "btn btn-light btn-sm")
