- if meta_file.errors
  ul.errors
    - meta_file.errors.each do |error|
      li = error.to_s

== form(action: "/meta_files/#{meta_file.id.to_s}", method: meta_file.id ? :patch : :post) do
  == csrf_tag
  .form-group
    == text_field(name: "hash", value: meta_file.hash, placeholder: "Hash", class: "form-control")
  .form-group
    == text_field(name: "size", value: meta_file.size, placeholder: "Size", class: "form-control")
  .form-group
    == text_field(name: "modification_time", value: meta_file.modification_time, placeholder: "Modification_time", class: "form-control")
  == submit("Submit", class: "btn btn-success btn-sm")
  == link_to("Back", "/meta_files", class: "btn btn-light btn-sm")
