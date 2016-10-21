class ImportFileDataJob < ApplicationJob
  queue_as :default

  before_perform do |job|
    job.arguments.first.update_attributes(status: 'in progress',
                                          skip_callbacks: true)
  end

  def perform(inventory_data_upload)
    FileReader::Reader.new inventory_data_upload
  end

  after_perform do |job|
    record = job.arguments.first
    unless record.status == 'error'
      record.update_attributes(status: 'finished',
                               skip_callbacks: true)
      ProcessDataJob.perform_later(record.user)
    end
  end
end
