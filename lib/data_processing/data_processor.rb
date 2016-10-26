module DataProcessing
  class DataProcessor
    class << self
      def prices_processing(received_inventories)
        received_inventories.each do |item|
          inventory = Inventory.where('msku = ? AND (date_purchased <= ? OR date_purchased IS NULL)', item.sku, item.received_date).first

          next unless inventory.present?

          if item.quantity.positive?
            total_price = inventory.price * item.quantity
            item.update_attributes(price_per_unit: inventory.price, price_total: total_price, cost_remain: total_price)
          else
            item.update_attribute(:price_per_unit, inventory.price)
          end
        end
      end

      def fulfillment_inbound_filling(received_inventories_priced, current_user)
        shipments_without_price = ReceivedInventory.where(price_total: nil).distinct.pluck(:fba_shipment_id)
        shipment_ids_all_items_priced = received_inventories_priced.where.not(fba_shipment_id: shipments_without_price).distinct.pluck(:fba_shipment_id)
        shipment_ids_all_items_priced.each do |item|
          request = ActiveRecord::Base.connection.execute("SELECT"\
                                                          "   SUM(quantity) AS total_quantity,"\
                                                          "   SUM(price_total) AS total_price,"\
                                                          "   MIN(received_date) AS date"\
                                                          " FROM received_inventories WHERE fba_shipment_id = '#{item}'")
          shipment_items_quantity = request.field_values('total_quantity').first
          shipment_total_cost = request.field_values('total_price').first
          shipment_minimal_date = request.field_values('date').first
          shipment_details = { shipment: item,
                               quantity: shipment_items_quantity,
                               cost: shipment_total_cost,
                               date: shipment_minimal_date }
          FulfillmentInboundShipment.create(fulfillment_inbound_shipment_params(shipment_details, current_user))
        end
      end

      def transaction_processing(report)
        transactions = report.transactions.type_order

        transactions.each do |transaction|
          marketplace = transaction.marketplace

          received_inventory_sold_processing(marketplace, transaction)

        end
        report.update_attribute(:processed, Time.zone.now)
      end

      private

      def received_inventory_sold_processing(marketplace, transaction, left_in_transaction = nil)
        left_in_transaction ||= transaction.quantity

        received_unsold_inventory = marketplace.received_inventories.with_unsold.order(received_date: :asc)
        item = received_unsold_inventory.first

        if item
          item_total_quantity = item.remain_units
          difference = item_total_quantity - left_in_transaction
          # byebug
          p '-----------------------'
          tmp = left_in_transaction unless difference < 0
          left_in_transaction = difference < 0 ? difference.abs : 0
          p left_in_transaction
          p '-----------------------'
          # left_in_transaction = 0 if dif_2
          if difference < 0
            # left_in_transaction is bigger that in current received inventory
            # we have one more received inventories
            # need find one more received_inventory
            item.update_attributes(sold_units: item.quantity,
                                   remain_units: 0,
                                   sold_date: transaction.date_time)
            received_inventory_sold_processing(marketplace, transaction, left_in_transaction)
          else
            sold_now = item.remain_units - difference
            # difference > 0
            # quantity of received inventory is bigger that left in transaction
            item.update_attributes(sold_units: item.sold_units + sold_now,
                                  remain_units: difference)
          end
          # if still left
          # if left and no received inventories
          # if all processed
          p 'finished'
        else
          # no more received inventories
          # but left_in_transaction is still present
          transaction.update_attribute(:unprocessed_quantity, left_in_transaction)
        end

      end

      def fulfillment_inbound_shipment_params(shipment_details, current_user)
        shipment_id = shipment_details[:shipment]
        marketplace_id = ReceivedInventory.where(fba_shipment_id: shipment_id, marketplace: current_user.marketplaces).distinct.pluck(:marketplace_id).first
        marketplace = Marketplace.find(marketplace_id)

        {
          marketplace: marketplace,
          shipment_id: shipment_id,
          price: shipment_details[:cost],
          total_received_units: shipment_details[:quantity],
          external_date_created: shipment_details[:date]
        }
      end
    end
  end
end
