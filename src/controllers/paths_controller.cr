class PathsController < ApplicationController
  # getter path = NodePath.new
  #
  # before_action do
  #   only [:show] { set_path_instances }
  # end

  def show
    path = NodePath.find!(params[:id])
    child_paths = NodePath.where(parent_node_path_id: params[:id]).order.order(basename: :asc)
    files = NodeFile.where(node_path_id: params[:id]).order(file_path: :asc)

    render "show.slang"
  end
end
