class ProcessDataJob < ApplicationJob
  queue_as :default

  def perform(user)
    received_inventories = ReceivedInventory.where(marketplace: user.marketplaces.pluck(:id)).where(price_total: 0)

    DataProcessing::DataProcessor.prices_processing(received_inventories)

    processed_shipments = FulfillmentInboundShipment.pluck(:shipment_id)
    received_inventories_with_price = ReceivedInventory.where.not(fba_shipment_id: processed_shipments, price_total: 0)

    DataProcessing::DataProcessor.fulfillment_inbound_filling(received_inventories_with_price, user)

    user.marketplaces.each do |marketplace|
      DataProcessing::DataProcessor.breakeven_date_processing_after_file_upload(marketplace)
    end
  end
end
