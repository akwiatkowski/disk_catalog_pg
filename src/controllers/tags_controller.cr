class TagsController < ApplicationController
  def index
    tags = Tag.all
    render "index.slang"
  end

  def show
    tag = Tag.find!(params[:id])
    paths = NodePath.where(tag_id: params[:id]).order(relative_path: :asc)
    render "show.slang"
  end
end
