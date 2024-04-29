- if path.errors
  ul.errors
    - path.errors.each do |error|
      li = error.to_s

== form(action: "/paths/#{path.id.to_s}", method: path.id ? :patch : :post) do
  == csrf_tag

  - tag_collection = [[nil, "N/A"]] + Tag.all.map{|tag| [tag.id, tag.name]}

  span Tag
  .form-group
    == select_field name: "tag_id", collection: tag_collection, selected: path.tag_id

  span Where to move tag
  .form-group
    == select_field name: "move_tag_id", collection: tag_collection, selected: path.move_tag_id

  == submit("Submit", class: "btn btn-success btn-sm")
  == link_to("Back", "/paths/#{path.id.to_s}", class: "btn btn-light btn-sm")
