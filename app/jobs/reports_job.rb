class ReportsJob < ApplicationJob
  queue_as :default

  def perform(user, marketplace, type)
    MWS::ImportService.request_report(user, marketplace, type)
  end
end
