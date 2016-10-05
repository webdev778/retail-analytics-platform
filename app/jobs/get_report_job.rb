class GetReportJob < ApplicationJob
  queue_as :default

  def perform(marketplace, id)
    MWS::ImportService.get_report_request_list(marketplace, id)
  end
end
