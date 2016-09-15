class ImportFileDataJob < ApplicationJob
  queue_as :urgent

  def perform(inventory_data_upload)
    FileReader::Reader.new inventory_data_upload
  end
end
