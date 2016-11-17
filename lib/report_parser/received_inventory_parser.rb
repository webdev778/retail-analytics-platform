# frozen_string_literal: true
module ReportParser
  class ReceivedInventoryParser
    def initialize(data, marketplace)
      @data = data
      @marketplace = marketplace
      received_inventory_processing
    end

    private

    def received_inventory_processing
      @data.each do |line|
        ReceivedInventory.create(received_inventory_params(line))
      end
      last_received_inventory = @marketplace.received_inventories.order(received_date: :desc).take(1)
      last_received_inventory_date = last_received_inventory.first.received_date
      @marketplace.update_attributes(get_received_inventory_finished: Time.zone.now,
                                     last_received_inventory_date: last_received_inventory_date)
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
