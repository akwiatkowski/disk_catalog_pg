class TreeHtmlHelper
  include JasperHelpers

  def initialize(@disk : Disk)
  end

  def to_html
    root_np = NodePath.find_by!(disk_id: @disk.id, parent_node_path_id: nil)

    return String.build do |s|
      s << "<ul>\n"
      s << node_path_to_html(root_np)
      s << "</ul>\n"
    end
  end

  def node_path_to_html(np)
    return String.build do |s|
      s << node_path_link_item(np)
      s << "<ul>\n"
      children_node_paths = NodePath.where(parent_node_path_id: np.id)
      children_node_paths.each do |childen_np|
        s << node_path_to_html(childen_np)
      end
      s << "</ul>\n"
    end
  end

  def node_path_link_item(np)
    return String.build do |s|
      s << "<li>"
      s << link_to(np.basename.to_s, "/paths/#{np.id.to_s}", class: "btn btn-light btn-sm")
      s << " - "
      s << "#{SizeTools.to_human(np.size)}"
      s << "</li>"
    end
  end
end
