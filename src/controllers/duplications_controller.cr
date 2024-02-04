class DuplicationsController < ApplicationController
  def need_duplication
    nps = NodePath.where("materialized_duplication_factor is not null and materialized_duplication_factor < 110")
    render "need_duplication.slang"
  end
end
