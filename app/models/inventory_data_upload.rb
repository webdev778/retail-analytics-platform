# frozen_string_literal: true
class InventoryDataUpload < ApplicationRecord
  has_attached_file :file_for_import

  validates_attachment_content_type :file_for_import,
                                    content_type: ['text/plain', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
                                    message: 'Allowed only .txt, .csv, .xls, .xlsx files extentions'
  validates_attachment_presence :file_for_import

  belongs_to :user

  attr_accessor :skip_callbacks

  after_commit :start_import, on: :create, unless: :skip_callbacks

  scope :successfully_finished, -> { where.not(finished_at: nil) }

  private

  def start_import
    ImportFileDataJob.perform_later(self)
  end
end
