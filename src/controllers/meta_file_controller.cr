class MetaFileController < ApplicationController
  getter meta_file = MetaFile.new

  before_action do
    only [:show, :edit, :update, :destroy] { set_meta_file }
  end

  def index
    meta_files = MetaFile.all
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
    meta_file = MetaFile.new meta_file_params.validate!
    if meta_file.save
      redirect_to action: :index, flash: {"success" => "Meta_file has been created."}
    else
      flash[:danger] = "Could not create MetaFile!"
      render "new.slang"
    end
  end

  def update
    meta_file.set_attributes meta_file_params.validate!
    if meta_file.save
      redirect_to action: :index, flash: {"success" => "Meta_file has been updated."}
    else
      flash[:danger] = "Could not update MetaFile!"
      render "edit.slang"
    end
  end

  def destroy
    meta_file.destroy
    redirect_to action: :index, flash: {"success" => "Meta_file has been deleted."}
  end

  private def meta_file_params
    params.validation do
      required :hash
      required :size
      required :modification_time
    end
  end

  private def set_meta_file
    @meta_file = MetaFile.find! params[:id]
  end
end
