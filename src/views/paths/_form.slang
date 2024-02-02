- if path.errors
  ul.errors
    - path.errors.each do |error|
      li = error.to_s

== form(action: "/paths/#{path.id.to_s}", method: path.id ? :patch : :post) do
  == csrf_tag
  .form-group
    - collection = [[nil, "N/A"]] + Tag.all.map{|tag| [tag.id, tag.name]}
    == select_field name: "tag_id", collection: collection, selected: path.tag_id
  == submit("Submit", class: "btn btn-success btn-sm")
  == link_to("Back", "/paths/#{path.id.to_s}", class: "btn btn-light btn-sm")
