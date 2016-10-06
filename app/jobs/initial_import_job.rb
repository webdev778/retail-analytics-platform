# class GetReportJob < ApplicationJob
#   queue_as :default
#
#   def perform(marketplace, id)
#     MWS::ImportService.request_report(marketplace, id)
#   end
# end
