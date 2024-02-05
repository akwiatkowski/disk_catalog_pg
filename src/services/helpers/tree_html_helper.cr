class TreeHtmlHelper
  include JasperHelpers

  MAX_LEVEL_DETAILED = 10
  MAX_LEVEL_BRIEF    =  2

  def initialize(
    @disk : Disk,
    show_all_levels : String?,
    @column_order : String? = "basename"
  )
    @show_all_levels = (show_all_levels.to_s.size >= 1).as(Bool)

    @max_level = MAX_LEVEL_BRIEF.as(Int32)
    @max_level = MAX_LEVEL_DETAILED.as(Int32) if @show_all_levels

    # some default order params
    @column_order = "basename" if @column_order.to_s == ""
    @order_direction = "asc"
    @order_direction = "desc" if @column_order == "size"
  end

  def to_html
    root_np = NodePath.find_by!(disk_id: @disk.id, parent_node_path_id: nil)

    return String.build do |s|
      s << "<ul>\n"
      s << node_path_to_html(root_np, level: 0)
      s << "</ul>\n"
    end
  end

  def node_path_to_html(np, level : Int32)
    return String.build do |s|
      if level <= @max_level
        s << node_path_link_item(np)
        s << "<ul>\n"
        children_node_paths = NodePath.where(parent_node_path_id: np.id).order({@column_order => @order_direction})
        children_node_paths.each do |childen_np|
          s << node_path_to_html(childen_np, level + 1)
        end
        s << "</ul>\n"
      end
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
