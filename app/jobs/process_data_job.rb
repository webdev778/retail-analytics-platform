class ProcessDataJob < ApplicationJob
  queue_as :default

  def perform(user)
    received_inventories = ReceivedInventory.where(marketplace: user.marketplaces.pluck(:id)).where(price_total: nil)

    DataProcessing::DataProcessor.prices_processing(received_inventories)

    processed_shipments = FulfillmentInboundShipment.pluck(:shipment_id)
    received_inventories_with_price = ReceivedInventory.where.not(fba_shipment_id: processed_shipments, price_total: nil)

    DataProcessing::DataProcessor.fulfillment_inbound_filling(received_inventories_with_price, user)
  end
end
