require 'populator'

namespace :db do
  desc 'fill database with fulfillment_inbound_shipments'
  task populate_fulfillment: :environment do
    FulfillmentInboundShipment.populate 10 do |item|
      item.shipment_id = Faker::Number.number(5)
      item.external_date_created = Faker::Time.between(2.days.ago, Date.today, :all)
      item.price = Faker::Number.decimal(2)
    end
  end

  desc 'fill database with transactions'
  task populate_transactions: :environment do
    ReceivedInventory.all.each do |received_inventory|
      Transaction.populate 2 do |item|
        received_date = received_inventory.received_date
        item.attributes = {
            marketplace_id: received_inventory.marketplace_id,
            date_time: Faker::Time.between(received_date, received_date + 3.days, :all),
            settlement_id: Faker::Number.number(9),
            type: 'demo',
            order_id: Faker::Number.number(9),
            sku: received_inventory.sku,
            quantity: Faker::Number.between(1, 10),
            product_sales: 0,
            shipping_credits: 0,
            gift_wrap_credits: 0,
            promotional_rebates: 0,
            selling_fees: 0,
            fba_fees: 0.5,
            other_transaction_fees: 0,
            shipping_price: 0,
            shipping_tax: 0,
            item_promotion_discount: 0,
            ship_promotion_discount: 0,
            other: 0,
            total: Faker::Number.between(10, 50),
        }
      end
    end
  end
end
