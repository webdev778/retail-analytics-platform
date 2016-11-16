# frozen_string_literal: true
class GetReportJob < ApplicationJob
  queue_as :default

  def perform(marketplace, id)
    MWS::ImportService.get_report_status(marketplace, id)
  end
end
