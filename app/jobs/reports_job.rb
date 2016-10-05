class ReportsJob < ApplicationJob
  queue_as :default

  def perform(marketplace, type)
    MWS::ImportService.request_report(marketplace, type)
  end
end
