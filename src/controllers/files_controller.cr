class FilesController < ApplicationController
  def show
    file = NodeFile.find!(params[:id])
    duplications = file.duplications

    render "show.slang"
  end
end
