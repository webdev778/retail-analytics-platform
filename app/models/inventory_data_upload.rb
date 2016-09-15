class InventoryDataUpload < ApplicationRecord
  has_attached_file :file_for_import

  validates_attachment_content_type :file_for_import,
                                    content_type: ['text/plain', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
                                    message: 'Allowed only .txt, .csv, .xls, .xlsx files extentions'
  validates_attachment_presence :file_for_import

  # ['text/csv', text/comma-separated-values', 'text/csv', application/csv', 'application/excel', 'application/vnd.ms-excel', 'application/vnd.msexcel', 'text/anytext', 'text/plain', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  belongs_to :user

  cattr_accessor :skip_callbacks

  after_save :start_import, unless: :skip_callbacks

  private

  def start_import
    ImportFileDataJob.new.perform(self)
  end
end
