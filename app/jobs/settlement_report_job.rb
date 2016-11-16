# frozen_string_literal: true
class SettlementReportJob < ApplicationJob
  queue_as :default

  def perform(user)
    unprocessed_settlement_reports = user.reports.settlement_reports.not_imported
    unprocessed_settlement_reports.each do |report|
      MWS::ImportService.get_settlement_report_data(report)
    end
  end

  after_perform do |job|
    user = job.arguments.first
    reports_for_process = user.reports.settlement_reports.imported.unprocessed.order(start_date: 'asc')
    reports_for_process.each do |report|
      DataProcessing::DataProcessor.transaction_processing(report)
    end
  end
end
