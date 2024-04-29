require "../../services/move/tag_move_script"

class Move::TagsController < ApplicationController
  def index
    tags = Tag.all
    render "index.slang"
  end

  def show
    tag = Tag.find!(params[:id])
    paths = NodePath.where(move_tag_id: params[:id]).order(relative_path: :asc)
    service = Move::TagMoveScript.new(tag)
    render "show.slang"
  end
end
