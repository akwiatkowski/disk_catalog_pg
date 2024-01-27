class PathsController < ApplicationController
  def index
    disks = Disk.all
    render "index.slang"
  end
end
