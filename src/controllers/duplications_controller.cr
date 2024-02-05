class DuplicationsController < ApplicationController
  @per_page = 20

  def need_duplication
    page = params[:page]? || 1
    scope = NodePath.where("materialized_duplication_factor is not null and materialized_duplication_factor < 110")
    nps = NodePath.order(size: :desc).where(
      "materialized_duplication_factor is not null and materialized_duplication_factor < 110"
    ).paginate(
      offset: page,
      limit: @per_page
    )
    count = scope.count

    render "need_duplication.slang"
  end
end
