module ReportParser
  class ParseService
    def initialize(data, report_type, marketplace, report = nil)
      @data = data
      @report = report
      @report_type = report_type
      @marketplace = marketplace
      check_report_type
    end

    def check_report_type
      p '.................'
      p @report_type
      p '.................'
      case @report_type
      when '_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_'
        received_inventory
      when '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_'
        ReportParser::SettlementParser.new(@data, @marketplace, @report)
      else
        Rails.logger.info('undefined report type')
      end
    end

    private

    def received_inventory
      @data.each do |line|
        ReceivedInventory.create(received_inventory_params(line))
      end
      @marketplace.update_attribute(:get_received_inventory_finished, Time.zone.now)
      ProcessDataJob.perform_later(@marketplace.user)
    end

    def received_inventory_params(file_line)
      total_quantity = file_line['quantity'].to_i
      {
        marketplace: @marketplace,
        received_date: file_line['received-date'].to_datetime,
        fnsku: file_line['fnsku'],
        sku: file_line['sku'],
        product_name: file_line['product-name'],
        quantity: total_quantity,
        remain_units: total_quantity,
        fba_shipment_id: file_line['fba-shipment-id']
      }
    end
  end
end
