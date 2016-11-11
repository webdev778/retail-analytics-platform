# frozen_string_literal: true
module DataProcessing
  class DataProcessor
    class << self
      def prices_processing(received_inventories)
        received_inventories.each do |item|
          inventory = Inventory
                      .where('msku = ? AND (date_purchased <= ? OR date_purchased IS NULL)', item.sku, item.received_date)
                      .first

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
        shipments_without_price = ReceivedInventory.where(price_total: 0)
                                                   .distinct
                                                   .pluck(:fba_shipment_id)
        shipment_ids_all_items_priced = received_inventories_priced
                                        .where.not(fba_shipment_id: shipments_without_price)
                                        .distinct
                                        .pluck(:fba_shipment_id)
        shipment_ids_all_items_priced.each do |item|
          request = ActiveRecord::Base.connection.execute('SELECT '\
                                                             'SUM(quantity) AS total_quantity, '\
                                                             'SUM(price_total) AS total_price, '\
                                                             'SUM(sold_units) AS total_sold, '\
                                                             'MIN(received_date) AS date, '\
                                                             'SUM(revenue) AS total_revenue '\
                                                            'FROM received_inventories '\
                                                             "WHERE fba_shipment_id = '#{item}'")
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

          breakeven_date_processing(marketplace, transaction)
        end

        transactions_refund = report.transactions.type_refund

        transactions_refund.each do |transaction|
          marketplace = transaction.marketplace
          received_inventory_refund_processing(marketplace, transaction) unless transaction.quantity.nil?
        end
        report.update_attribute(:processed, Time.zone.now)
      end

      def breakeven_date_processing_after_file_upload(marketplace)
        # shipments = FulfillmentInboundShipment.where(breakeven_date: nil)
        # ReceivedInventory.where(fba_shipment_id: shipments.pluck(:shipment_id))
        shipments_with_inventory = FulfillmentInboundShipment.joins('LEFT JOIN received_inventories ON fulfillment_inbound_shipments.shipment_id = received_inventories.fba_shipment_id').select('fulfillment_inbound_shipments.*, received_inventories.*').where('fulfillment_inbound_shipments.marketplace_id = ?', marketplace.id)
        skus = shipments_with_inventory.distinct(:sku).pluck(:sku, :shipment_id)
        result = {}
        skus.each do |item|
          if result.key?(item.second)
            #     add value
            result[item.second].push item.first
          else
            #   add key with value into result
            result[item.second] = [item.first]
          end
        end

        result.each do |fba_with_skus|
          # tr = Transaction.where(sku: fba_with_skus.second).order(:date_time)
          skus = fba_with_skus.second
          shipment_id = fba_with_skus.first
          request = ActiveRecord::Base.connection.execute('SELECT '\
                                                                'SUM(revenue) AS total_revenue, '\
                                                                'SUM(fees) AS total_fees '\
                                                               'FROM received_inventories '\
                                                              "WHERE marketplace_id = '#{marketplace.id}' "\
                                                               "AND fba_shipment_id = '#{shipment_id}' "\
                                                               "AND sku IN ('#{skus.join("','")}')")
          revenue = request.field_values('total_revenue').first
          fees = request.field_values('total_fees').first

          total_profit = revenue.to_f - fees.to_f

          shipment = FulfillmentInboundShipment.find_by(shipment_id: shipment_id)

          find_right_transaction(shipment, skus, marketplace) if total_profit >= shipment.price.to_f
        end
      end

      def find_right_transaction(shipment, skus_in_shipment, marketplace, quantity_of_transactions = 1)

        transactions = Transaction.where(sku: skus_in_shipment).order(:date_time).take(quantity_of_transactions)
        skus = transactions.pluck(:sku)

        request = ActiveRecord::Base.connection.execute('SELECT '\
                                                                'SUM(revenue) AS total_revenue, '\
                                                                'SUM(fees) AS total_fees '\
                                                               'FROM received_inventories '\
                                                              "WHERE marketplace_id = '#{marketplace.id}' "\
                                                               "AND fba_shipment_id = '#{shipment.shipment_id}' "\
                                                               "AND sku IN ('#{skus.join("','")}')")

        revenue = request.field_values('total_revenue').first
        fees = request.field_values('total_fees').first

        total_profit = revenue.to_f - fees.to_f

        if total_profit >= shipment.price.to_f
          shipment.update_attribute(:breakeven_date, transactions.last.date_time)
        else
          find_right_transaction(shipment, skus_in_shipment, marketplace, quantity_of_transactions + 1)
        end
      end

      private

      def breakeven_date_processing(marketplace, transaction)
        shipments_ids = marketplace.received_inventories.where(sku: transaction.sku).distinct.pluck(:fba_shipment_id)
        shipments_ids.each do |id|
          shipments = marketplace.fulfillment_inbound_shipments.where(shipment_id: id)
          shipments.each do |item|
            # SUM((revenue - fees - cost_sold) + cost_sold) >= SUM(price_total)
            # ('SELECT '\
            #                                                     'SUM(revenue) AS total_revenue, '\
            #                                                     'SUM(fees) AS total_fees, '\
            #                                                     'SUM(cost_sold) AS total_sold '\
            #                                                    'FROM received_inventories '\
            #                                                   "WHERE marketplace_id = '#{marketplace.id}' "\
            #                                                    "AND fba_shipment_id = '#{item.shipment_id}'")
            # SUM(revenue - fees)
            request = ActiveRecord::Base.connection.execute('SELECT '\
                                                                'SUM(revenue) AS total_revenue, '\
                                                                'SUM(fees) AS total_fees '\
                                                               'FROM received_inventories '\
                                                              "WHERE marketplace_id = '#{marketplace.id}' "\
                                                               "AND fba_shipment_id = '#{item.shipment_id}'")

            revenue = request.field_values('total_revenue').first
            fees = request.field_values('total_fees').first
            # cost_sold = request.field_values('total_sold').first

            # total_profit = revenue.to_f - fees.to_f - cost_sold.to_f
            total_profit = revenue.to_f - fees.to_f
            item.update_attribute(:breakeven_date, transaction.date_time) if total_profit >= item.price.to_f
          end
        end
      end

      def received_inventory_refund_processing(marketplace, transaction, left_for_return = nil)
        quantity = transaction.unprocessed_quantity.positive? ? transaction.unprocessed_quantity : transaction.quantity
        left_for_return ||= quantity

        received_inventory_for_processing = marketplace.received_inventories.positive_quantity
                                                       .where('returned_units < quantity')
                                                       .where('received_date <= ?', transaction.date_time)
                                                       .where(sku: transaction.sku)
                                                       .order(received_date: :asc)
        item = received_inventory_for_processing.first

        if item
          difference = item.quantity - left_for_return
          if difference.negative?
            left_for_return = difference.abs
            returned_quantity = left_for_return + difference
            item.update_attributes(returned_units: returned_quantity,
                                   returned_cost: item.price_per_unit * returned_quantity)
            received_inventory_refund_processing(marketplace, transaction, left_for_return)
          else
            item.update_attributes(returned_units: left_for_return,
                                   returned_cost: item.price_per_unit * left_for_return)
          end
        end
      end

      def received_inventory_sold_processing(marketplace, transaction, left_in_transaction = nil)
        quantity = transaction.unprocessed_quantity.positive? ? transaction.unprocessed_quantity : transaction.quantity
        left_in_transaction ||= quantity
        received_unsold_inventory = marketplace.received_inventories
                                               .with_unsold
                                               .where('received_date <= ?', transaction.date_time)
                                               .where(sku: transaction.sku)
                                               .order(received_date: :asc)
        item = received_unsold_inventory.first

        if item
          item_total_quantity = item.remain_units
          difference = item_total_quantity - left_in_transaction

          left_in_transaction = difference.negative? ? difference.abs : 0

          total_fees = transaction.selling_fees + transaction.fba_fees + transaction.other_transaction_fees + item.fees

          if difference.negative?
            # left_in_transaction is bigger that in current received inventory
            # we have one more received inventories
            # need find one more received_inventory
            item.update_attributes(sold_units: item.quantity,
                                   cost_sold: item.quantity * item.price_per_unit,
                                   remain_units: 0,
                                   cost_remain: 0,
                                   sold_date: transaction.date_time,
                                   revenue: item.revenue + transaction.product_sales,
                                   fees: total_fees)
            received_inventory_sold_processing(marketplace, transaction, left_in_transaction)
          else

            # difference > 0
            # quantity of received inventory is bigger that left in transaction
            date = difference.zero? ? transaction.date_time : nil
            sold_now = item.remain_units - difference
            total_sold = item.sold_units + sold_now
            item.update_attributes(sold_units: total_sold,
                                   cost_sold: total_sold * item.price_per_unit,
                                   remain_units: difference,
                                   cost_remain: difference * item.price_per_unit,
                                   sold_date: date,
                                   revenue: item.revenue + transaction.product_sales,
                                   fees: total_fees)
            transaction.update_attribute(:unprocessed_quantity, 0)
          end
        else
          # no more received inventories
          # but left_in_transaction is still present
          transaction.update_attribute(:unprocessed_quantity, left_in_transaction)
        end
      end

      def fulfillment_inbound_shipment_params(shipment_details, current_user)
        shipment_id = shipment_details[:shipment]
        marketplace_id = ReceivedInventory.where(fba_shipment_id: shipment_id,
                                                 marketplace: current_user.marketplaces)
                                          .distinct.pluck(:marketplace_id)
                                          .first
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
