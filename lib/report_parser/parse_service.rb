# frozen_string_literal: true
module ReportParser
  class ParseService
    def initialize(data, report_type, marketplace, report = nil)
      @data = data
      @report = report
      @report_type = report_type
      @marketplace = marketplace
      check_report_type
    end

    private

    def check_report_type
      Rails.logger.info(@report_type)
      case @report_type
      when '_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_'
        ReportParser::ReceivedInventoryParser.new(@data, @marketplace)
      when '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_'
        ReportParser::SettlementParser.new(@data, @marketplace, @report)
      else
        Rails.logger.info('undefined report type')
      end
    end
  end
end
