class ImportedFilesCleaningJob < ApplicationJob
  queue_as :default
  KEEPT_RECORDS = 5

  def perform(user)
    users_uploads_count = user.inventory_data_uploads.successfully_finished.length
    if users_uploads_count > KEEPT_RECORDS
      overlimited_records_count = users_uploads_count - KEEPT_RECORDS
      user.inventory_data_uploads.order(created_at: :asc).limit(overlimited_records_count).destroy_all
    end
  end
end
