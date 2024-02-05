h1
  == "disk: "
  == disk.name

Show:
== link_to("all levels", "/disks/#{disk.id.to_s}?column_order=#{params[:column_order]?}&show_all_levels=t", class: "btn btn-light btn-sm")
|
== link_to("only #{TreeHtmlHelper::MAX_LEVEL_BRIEF} levels", "/disks/#{disk.id.to_s}?column_order=#{params[:column_order]?}&show_all_levels=", class: "btn btn-light btn-sm")
|
Order by
== link_to("name", "/disks/#{disk.id.to_s}?column_order=basename&show_all_levels=#{params[:show_all_levels]?}", class: "btn btn-light btn-sm")
|
== link_to("size", "/disks/#{disk.id.to_s}?column_order=size&show_all_levels=#{params[:show_all_levels]?}", class: "btn btn-light btn-sm")


== tree_html

== link_to("Back", "/disks", class: "btn btn-light btn-sm")
