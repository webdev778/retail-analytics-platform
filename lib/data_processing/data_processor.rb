module DataProcessing
  class DataProcessor
    class << self
      def prices_processing(received_inventories)
        received_inventories.each do |item|
          inventory = Inventory.where('msku = ? AND (date_purchased <= ? OR date_purchased IS NULL)', item.sku, item.received_date).first

          next unless inventory.present?

          if item.quantity.positive?
            total_price = inventory.price * item.quantity
            item.update_attributes(price_per_unit: inventory.price,
                                   price_total: total_price,
                                   cost_remain: inventory.price * item.remain_units,
                                   cost_sold: inventory.price * item.sold_units)
          else
            item.update_attribute(:price_per_unit, inventory.price)
          end
        end
      end

      def fulfillment_inbound_filling(received_inventories_priced, current_user)
        shipments_without_price = ReceivedInventory.where(price_total: 0).distinct.pluck(:fba_shipment_id)
        shipment_ids_all_items_priced = received_inventories_priced.where.not(fba_shipment_id: shipments_without_price).distinct.pluck(:fba_shipment_id)
        shipment_ids_all_items_priced.each do |item|
          request = ActiveRecord::Base.connection.execute("SELECT"\
                                                          "   SUM(quantity) AS total_quantity,"\
                                                          "   SUM(price_total) AS total_price,"\
                                                          "   SUM(sold_units) AS total_sold,"\
                                                          "   MIN(received_date) AS date,"\
                                                          "   SUM(revenue) AS total_revenue"\
                                                          " FROM received_inventories WHERE fba_shipment_id = '#{item}'")
          shipment_items_quantity = request.field_values('total_quantity').first
          shipment_total_cost = request.field_values('total_price').first
          shipment_total_sold = request.field_values('total_sold').first
          shipment_total_revenue = request.field_values('total_revenue').first
          shipment_minimal_date = request.field_values('date').first
          shipment_details = { shipment: item,
                               quantity: shipment_items_quantity,
                               sold: shipment_total_sold,
                               cost: shipment_total_cost,
                               revenue: shipment_total_revenue,
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

          left_in_transaction = difference < 0 ? difference.abs : 0

          total_fees = transaction.selling_fees + transaction.fba_fees + transaction.other_transaction_fees + item.fees

          if difference < 0
            # left_in_transaction is bigger that in current received inventory
            # we have one more received inventories
            # need find one more received_inventory

            item.update_attributes(sold_units: item.quantity,
                                   cost_sold: item.quantity * item.price_per_unit,
                                   remain_units: 0,
                                   cost_remain: 0,
                                   sold_date: transaction.date_time,
                                   revenue: item.revenue + transaction.total,
                                   fees: total_fees)
            received_inventory_sold_processing(marketplace, transaction, left_in_transaction)
          else
            sold_now = item.remain_units - difference
            # difference > 0
            # quantity of received inventory is bigger that left in transaction
            date = difference == 0 ? transaction.date_time : nil
            total_sold = item.sold_units + sold_now
            item.update_attributes(sold_units: total_sold,
                                   cost_sold: total_sold * item.price_per_unit,
                                   remain_units: difference,
                                   cost_remain: difference * item.price_per_unit,
                                   sold_date: date,
                                   revenue: item.revenue + transaction.total,
                                   fees: total_fees)
          end
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
          total_sold: shipment_details[:sold],
          total_revenue: shipment_details[:revenue],
          external_date_created: shipment_details[:date]
        }
      end
    end
  end
end
