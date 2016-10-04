module MWS
  class ImportService
    class << self
      def connect!(user, marketplace)
        MWS::Reports::Client.new(
            primary_marketplace_id: marketplace.external_marketplace_id,
            merchant_id: marketplace.account.seller_id,
            aws_access_key_id: marketplace.aws_access_key_id,
            aws_secret_access_key: marketplace.secret_key,
            auth_token: marketplace.account.mws_auth_token
        )
      end

      def request_report(user, marketplace, report_type)
        # '_GET_RESERVED_INVENTORY_DATA_'---
        # _GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_ for first data
        # '_GET_AMAZON_FULFILLED_SHIPMENTS_DATA_'

        # _GET_AMAZON_FULFILLED_SHIPMENTS_DATA_ ???

        response = connect!(user, marketplace).request_report(report_type)
        response = response.parse

        if response['ReportRequestInfo']['ReportRequestId'].present?
          GetReportJob.set(wait: 1.minute).perform_later(user, marketplace, response['ReportRequestInfo']['ReportRequestId'])
        end
      end

      def initial_import(user, marketplace)
        ReportsJob.perform_later(user, marketplace, '_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_')
      end

      def get_report_request_list(user, marketplace, id)
        response = connect!(user, marketplace).get_report_request_list(report_request_id_list: [id])
        response = response.parse
        if response['ReportRequestInfo']['ReportProcessingStatus'] == '_DONE_'
          get_data(user, marketplace, response['ReportRequestInfo']['GeneratedReportId'], response['ReportRequestInfo']['ReportType'])
        elsif response['ReportRequestInfo']['ReportProcessingStatus'] == '_CANCELLED_'
          get_previous_report(user, marketplace, id, [response['ReportRequestInfo']['ReportType']])
        elsif response['ReportRequestInfo']['ReportProcessingStatus'] == '_DONE_NO_DATA_'
          request_report(user, marketplace, response['ReportRequestInfo']['ReportType'])
        else
          GetReportJob.set(wait: 1.minute).perform_later(user, marketplace, id)
        end
      end

      def get_previous_report(user,marketplace, id, report_type)
        response = connect!(user, marketplace).get_report_request_list(report_type_list: [report_type], report_processing_status_list: ['_DONE_'])
        if response.parse['ReportRequestInfo'].first.present?
          previous_done_report = response.parse['ReportRequestInfo'].first
          p '------------------------------------------------'
          p previous_done_report['GeneratedReportId']
          p '------------------------------------------------'
          previous_done_report_id = previous_done_report['GeneratedReportId']
          get_data(user, marketplace, previous_done_report_id, report_type)
          Rails.logger.info("Previous report #{previous_done_report_id} was get instead of #{id}")
        else
          Rails.logger.info("Issue with report #{id} no previous report found")
        end
      end

      def get_data(user, marketplace, id, report_type)
        response = connect!(user, marketplace).get_report(id)
        response = response.parse
        p '!!!!!!!!!!!!'
        p response.headers
        p '!!!!!!!!!!!!'
        ReportParser::ParseService.new(response, report_type, marketplace)
      end
    end

    def initialize(user, marketplace)
      @reports_client = MWS::ImportService.connect!(user, marketplace)
    end

    # private
    # def status_check
    #   #return {"Status"=>"GREEN", "Timestamp"=>"2016-09-21T12:50:49.979Z"}
    #   @marketplace.get_service_status.parse
    # end

    # def get_fulfillment_inbound_shipments_list
    #   # client.list_inbound_shipments({shipment_status_list: 'closed'})
    #   # statuses = %w(working shipped in_transit delivered checked_in receiving closed cancelled)
    #   statuses = 'working'
    #   response = @marketplace.list_inbound_shipments({ shipment_status_list: statuses })
    #   response = response.parse
    #   response_complete = []
    #   response_complete << response
    #   while response["NextToken"].present? do
    #     response =  @marketplace.list_inbound_shipments_by_next_token(response["NextToken"])
    #     response = response.parse
    #     response_complete << response
    #   end
    #   response_complete
    #   response_complete.each do |response|
    #     response['ShipmentData']['member'].each do |response_part|
    #       p '------------------------------------------------'
    #       p response_part
    #       p response_part['ShipmentId']
    #       p response_part.try(:[], 'EstimatedBoxContentsFee')
    #       p response_part['ShipmentName']
    #       p '------------------------------------------------'
    #     end
    #   end
    # end
  end
end
