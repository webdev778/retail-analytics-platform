# frozen_string_literal: true
class InventoriesDataUploadsController < ApplicationController
  after_action :file_records_cleaning, only: :create

  def new
    @inventory_data_upload = InventoryDataUpload.new
    @inventory_data_uploads = current_user.inventory_data_uploads.order(created_at: :desc)
    @inventories = current_user.inventories.page params[:page]
  end

  def create
    @inventory_data_upload = InventoryDataUpload.new(inventory_data_upload_params)

    if @inventory_data_upload.save
      flash[:notice] = 'File will be proceed in few minutes.'
      redirect_to new_inventories_data_upload_path
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
