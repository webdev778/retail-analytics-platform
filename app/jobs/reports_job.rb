class ReportsJob < ApplicationJob
  queue_as :default

  def perform(marketplace, type, initial_import = nil)
    MWS::ImportService.request_report(marketplace, type)
  end

  after_perform do |job|
    MWS::ImportService.get_settlement_reports_info(job.arguments.first) if job.arguments.last
  end
end
