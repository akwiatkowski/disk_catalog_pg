class PathsController < ApplicationController
  getter path = NodePath.new

  before_action do
    only [:show, :edit, :update] { set_path }
  end

  def show
    child_paths = NodePath.where(parent_node_path_id: params[:id]).order(basename: :asc)
    files = NodeFile.where(node_path_id: params[:id]).order(file_path: :asc)

    render "show.slang"
  end

  def edit
    render "edit.slang"
  end

  def update
    path.set_attributes path_params.validate!
    if path.save
      redirect_to "/paths/#{path.id}", flash: {"success" => "Path has been updated."}
    else
      flash[:danger] = "Could not update path!"
      render "edit.slang"
    end
  end

  private def path_params
    params.validation do
      required :tag_id
    end
  end

  private def set_path
    @path = NodePath.find!(params[:id])
  end
end
