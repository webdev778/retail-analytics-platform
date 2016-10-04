class GetReportJob < ApplicationJob
  queue_as :default

  def perform(user, marketplace, id)
    MWS::ImportService.get_report_request_list(user, marketplace, id)
  end
end
