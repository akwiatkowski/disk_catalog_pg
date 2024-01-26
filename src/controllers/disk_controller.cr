require "../services/scanner_service"

class DiskController < ApplicationController
  getter disk = Disk.new

  before_action do
    only [:show, :edit, :update, :destroy, :scan] { set_disk }
  end

  def index
    disks = Disk.all
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

  def scan
    service = ScannerService.new(disk: disk)
    service.scan
    redirect_to action: :index, flash: {"success" => "Disk #{disk.name} has been scanned"}
  end

  def create
    disk = Disk.new disk_params.validate!
    if disk.save
      redirect_to action: :index, flash: {"success" => "Disk has been created."}
    else
      flash[:danger] = "Could not create Disk!"
      render "new.slang"
    end
  end

  def update
    disk.set_attributes disk_params.validate!
    if disk.save
      redirect_to action: :index, flash: {"success" => "Disk has been updated."}
    else
      flash[:danger] = "Could not update Disk!"
      render "edit.slang"
    end
  end

  def destroy
    disk.destroy
    redirect_to action: :index, flash: {"success" => "Disk has been deleted."}
  end

  private def disk_params
    params.validation do
      required :name
      required :path
      required :size
    end
  end

  private def set_disk
    @disk = Disk.find! params[:id]
  end
end
