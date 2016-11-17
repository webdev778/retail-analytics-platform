# frozen_string_literal: true
class ReportsJob < ApplicationJob
  queue_as :default

  def perform(marketplace, type, initial_import = nil)
    start_date = initial_import ? 3.month.ago : (marketplace.last_received_inventory_date + 1.minute)
    MWS::ImportService.request_report(marketplace, type, start_date)
  end

  after_perform do |job|
    MWS::ImportService.get_settlement_reports_info(job.arguments.first) if job.arguments.last
  end
end
