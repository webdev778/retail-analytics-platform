module ReportParser
  class ParseService
   def initialize(data, report_type, marketplace)
     @data = data
     @report_type = report_type
     @marketplace = marketplace
     check_report_type
   end

    def check_report_type
      p '>>>>>>>>>>>.................'
      p @report_type
      p '>>>>>>>>>>>.................'
      case @report_type
      when ['_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_']
        received_inventory
      else
        p '------------------------------'
      end
    end

    def first_report
      @data.each do |line|
        p "#{line['fba-shipment-id']} #{line['received-date']} #{line['fnsku']}"
      end
    end

    def received_inventory
      @data.each do |line|
        ReceivedInventory.create(received_inventory_params(line, @marketplace))
      end
    end

    private

    def received_inventory_params(file_line, marketplace)
      {
          marketplace: marketplace,
          fnsku: file_line['fnsku'],
          sku: file_line['sku'],
          product_name: file_line['product-name'],
          quantity: file_line['quantity'],
          fba_shipment_id: file_line['fba-shipment-id']
      }
    end

  end
end
