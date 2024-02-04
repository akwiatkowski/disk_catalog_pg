class FilesController < ApplicationController
  def show
    file = JoinedFile.find!(params[:id])
    duplications = file.duplications

    render "show.slang"
  end

  def search
    query = false
    count = 0
    files = Array(JoinedFile).new

    if params[:query]?.to_s.size > 2
      query = true
      scope = JoinedFile.where("file_path ilike '%#{params[:query]}%'")
      count = scope.count
      files = scope.limit(100)
    end

    render "search.slang"
  end
end
