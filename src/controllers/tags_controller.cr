class TagsController < ApplicationController
  def show
    tag = Tag.find!(params[:id])
    # paths = tag.node_paths.order(relative_path: :asc)
    paths = NodePath.where(tag_id: params[:id]).order(relative_path: :asc)
    render "show.slang"
  end
end
