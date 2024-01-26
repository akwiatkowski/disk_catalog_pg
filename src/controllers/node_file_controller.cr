class NodeFileController < ApplicationController
  getter node_file = NodeFile.new

  before_action do
    only [:show, :edit, :update, :destroy] { set_node_file }
  end

  def index
    node_files = NodeFile.all
    render "index.slang"
  end

  def show
    render "show.slang"
  end

  def new
    render "new.slang"
  end

  def edit
    render "edit.slang"
  end

  def create
    node_file = NodeFile.new node_file_params.validate!
    if node_file.save
      redirect_to action: :index, flash: {"success" => "Node_file has been created."}
    else
      flash[:danger] = "Could not create NodeFile!"
      render "new.slang"
    end
  end

  def update
    node_file.set_attributes node_file_params.validate!
    if node_file.save
      redirect_to action: :index, flash: {"success" => "Node_file has been updated."}
    else
      flash[:danger] = "Could not update NodeFile!"
      render "edit.slang"
    end
  end

  def destroy
    node_file.destroy
    redirect_to action: :index, flash: {"success" => "Node_file has been deleted."}
  end

  private def node_file_params
    params.validation do
      required :meta_file_id
      required :disk_id
      required :file_path
    end
  end

  private def set_node_file
    @node_file = NodeFile.find! params[:id]
  end
end
