# frozen_string_literal: true
class Report < ApplicationRecord
  belongs_to :user
  belongs_to :marketplace

  has_many :transactions

  validates_uniqueness_of :generated_report_id, scope: [:user_id, :marketplace_id, :start_date, :end_date, :report_type]

  enum report_type: %w(_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_)

  scope :settlement_reports, -> { where(report_type: '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_') }

  scope :unprocessed, -> { where(processed: nil) }
  scope :processed, -> { where.not(processed: nil) }

  scope :not_imported, -> { where(get_data: nil) }
  scope :imported, -> { where.not(get_data: nil) }
end
