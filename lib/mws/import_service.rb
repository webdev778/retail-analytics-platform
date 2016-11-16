# frozen_string_literal: true
module MWS
  class ImportService
    class << self
      def check_connection(account, marketplace)
        begin
          client = MWS::Sellers::Client.new(
            primary_marketplace_id: marketplace.external_marketplace_id,
            merchant_id: account.seller_id,
            aws_access_key_id: marketplace.aws_access_key_id,
            aws_secret_access_key: marketplace.secret_key,
            auth_token: account.mws_auth_token
          )
          participation = client.list_marketplace_participations
          participation = participation.parse
          marketplace_presence = false
          participation['ListParticipations']['Participation'].each do |item|
            marketplace_presence = true if item['MarketplaceId'] == marketplace.external_marketplace_id
          end
        rescue => e
          Rails.logger.info('wrong credentials')
          Rails.logger.info(e.inspect)
          marketplace_presence = false
          false
        end
        marketplace_presence
      end

      def connect!(marketplace)
        MWS::Reports::Client.new(
          primary_marketplace_id: marketplace.external_marketplace_id,
          merchant_id: marketplace.account.seller_id,
          aws_access_key_id: marketplace.aws_access_key_id,
          aws_secret_access_key: marketplace.secret_key,
          auth_token: marketplace.account.mws_auth_token
        )
      end

      def request_report(marketplace, report_type)
        # _GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_
        # _GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_
        response = connect!(marketplace).request_report(report_type)
        response = response.parse
        if response['ReportRequestInfo']['ReportRequestId'].present?
          Rails.logger.info("!!!Report request - #{response['ReportRequestInfo']['ReportRequestId']}!!!")
          GetReportJob.set(wait: 1.minute).perform_later(marketplace, response['ReportRequestInfo']['ReportRequestId'])
          report_request_id = response['ReportRequestInfo']['ReportRequestId']
        end

        report_request_id || response.parse
      end

      def initial_import(marketplace)
        ReportsJob.perform_later(marketplace, '_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_', true)
      end

      def get_report_status(marketplace, id)
        response = connect!(marketplace).get_report_request_list(report_request_id_list: [id])
        response = response.parse
        report_status = response['ReportRequestInfo']['ReportProcessingStatus']
        report_type = response['ReportRequestInfo']['ReportType']
        Rails.logger.info("!!!Report #{id} status - #{report_status} - #{report_type}!!!")
        if report_status == '_DONE_'
          get_data(marketplace, response['ReportRequestInfo']['GeneratedReportId'], report_type)
        elsif report_status == '_CANCELLED_'
          get_previous_report(marketplace, report_type, true)
        elsif report_status == '_DONE_NO_DATA_'
          request_report(marketplace, report_type)
        else
          GetReportJob.set(wait: 1.minute).perform_later(marketplace, id)
        end

        report_status
      end

      def get_previous_report(marketplace, report_type, _initial = nil)
        response = connect!(marketplace).get_report_request_list(report_type_list: report_type,
                                                                 report_processing_status_list: '_DONE_')
        reports = []
        response.parse['ReportRequestInfo'].each do |report|
          reports << report if report['StartDate'] <= 3.month.ago
        end
        if reports.present?
          report = reports.sort_by { |item| item[:StartDate] }.first
          get_data(marketplace, report['GeneratedReportId'], report_type)
        else
          # queue in 1 hour new report request
          ReportsJob.set(wait: 1.hour).perform_later(marketplace, report_type)
        end
        # if response.parse['ReportRequestInfo'].present?
        #   # response.parse['ReportRequestInfo'].each do |report|
        #     # report['StartDate']
        #   # end
        #   # previous_done_report = response.parse['ReportRequestInfo'].first
        #   # previous_done_report_id = previous_done_report['GeneratedReportId']
        #   get_data(marketplace, previous_done_report_id, report_type)
        #   Rails.logger.info("Previous report #{previous_done_report_id} was get instead of #{id}")
        # else
        #   # queue new report request in few hours
        #   Rails.logger.info("Issue with report #{id} no previous report found")
        # end
      end

      def get_data(marketplace, id, report_type)
        response = connect!(marketplace).get_report(id)
        response = response.parse
        ReportParser::ParseService.new(response, report_type, marketplace)
      end

      def get_settlement_reports_info(marketplace)
        response = connect!(marketplace).get_report_request_list(report_type_list: '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_',
                                                                 report_processing_status_list: '_DONE_')
        response = response.parse
        response['ReportRequestInfo'].each do |item|
          Report.find_or_create_by(report_params(item, marketplace))
        end
        SettlementReportJob.set(wait: 5.minutes).perform_later(marketplace.user)
      end

      def get_settlement_report_data(report)
        marketplace = report.marketplace
        response = connect!(marketplace).get_report(report.generated_report_id)
        response = response.parse
        ReportParser::ParseService.new(response, report.report_type, marketplace, report)
        report.update_attributes(get_data: Time.zone.now)
      end

      private

      def report_params(params, marketplace)
        {
          marketplace: marketplace,
          user: marketplace.user,
          generated_report_id: params['GeneratedReportId'],
          start_date: params['StartDate'],
          end_date: params['EndDate'],
          report_type: params['ReportType']
        }
      end
    end

    def initialize(marketplace)
      @reports_client = MWS::ImportService.connect!(marketplace)
    end
  end
end
