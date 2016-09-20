class InventoriesDataUploadsController < ApplicationController

  after_action :file_records_cleaning, only: :create

  def index
    @inventory_data_uploads = current_user.inventory_data_uploads
  end

  def new
    @inventory_data_upload = InventoryDataUpload.new
  end

  def create
    @inventory_data_upload = InventoryDataUpload.new(inventory_data_upload_params)

    if @inventory_data_upload.save
      flash[:notice] = 'File will be proceed in few minutes.'
      redirect_to inventories_data_uploads_path
    else
      render :new
    end
  end

  private


  def inventory_data_upload_params
    params.require(:inventory_data_upload).permit(:file_for_import).merge(user: current_user) if params[:inventory_data_upload]
  end

  def file_records_cleaning
    ImportedFilesCleaningJob.perform_later(@inventory_data_upload.user)
  end
end
