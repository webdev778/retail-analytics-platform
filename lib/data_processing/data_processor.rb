module DataProcessing
  class DataProcessor
    class << self
      def prices_processing(received_inventories)
        received_inventories.each do |item|
          inventory = Inventory.where('msku = ? AND (date_purchased <= ? OR date_purchased IS NULL)', item.sku, item.received_date).first

          next unless inventory.present?

          if item.quantity.positive?
            item.update_attributes(price_per_unit: inventory.price, price_total: inventory.price * item.quantity)
          else
            item.update_attribute(:price_per_unit, inventory.price)
          end
        end
      end

      def fulfillment_inbound_filling(received_inventories_priced, current_user)
        shipments_without_price = ReceivedInventory.where(price_total: nil).distinct.pluck(:fba_shipment_id)
        shipment_ids_all_items_priced = received_inventories_priced.where.not(fba_shipment_id: shipments_without_price).distinct.pluck(:fba_shipment_id)

        shipment_ids_all_items_priced.each do |item|
          shipment_cost = ReceivedInventory.where(fba_shipment_id: item).sum(:price_total)
          fulfillment_inbound_shipment_params(shipment_cost, item, current_user)
          FulfillmentInboundShipment.create(fulfillment_inbound_shipment_params(shipment_cost, item, current_user))
        end
      end

      private

      def fulfillment_inbound_shipment_params(cost, shipment_id, current_user)
        # ReceivedInventory.find_by(fba_shipment_id: shipment_id, )
        marketplace_id = ReceivedInventory.where(fba_shipment_id: shipment_id, marketplace: current_user.marketplaces).distinct.pluck(:marketplace_id).first
        marketplace = Marketplace.find(marketplace_id)

        {
          marketplace: marketplace,
          shipment_id: shipment_id,
          price: cost
        }
      end
    end
  end
end