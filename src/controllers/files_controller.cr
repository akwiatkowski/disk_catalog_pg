class FilesController < ApplicationController
  def show
    file = NodeFile.find!(params[:id])
    duplications = file.duplications

    render "show.slang"
  end

  def search
    # TODO: create PG view with file size

    # basename or relative_path
    scope = NodeFile.where("file_path ilike '%#{params[:query]}%'")
    # scope = NodeFile.where(["file_path ilike '%?%'", params[:query]])
    count = scope.count
    files = scope.limit(100)

    render "search.slang"
  end
end
