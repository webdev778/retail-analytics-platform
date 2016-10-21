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
  task populate_inventory_calculated_fields: :environment do
    ReceivedInventory.all.each do |received_inventory|
      received_inventory.price_per_unit = Faker::Number.between(4, 100)
      received_inventory.price_total = received_inventory.price_per_unit * received_inventory.quantity
      received_inventory.sold_date = received_inventory.received_date.to_datetime + Faker::Number.between(20, 80).days
      received_inventory.sold_units = received_inventory.quantity - Faker::Number.between(0, received_inventory.quantity)
      received_inventory.cost_sold = received_inventory.sold_units * received_inventory.price_per_unit
      received_inventory.remain_units = received_inventory.quantity - received_inventory.sold_units
      received_inventory.cost_remain = received_inventory.remain_units * received_inventory.price_per_unit
      item_revenue = received_inventory.price_per_unit * Faker::Number.between(170, 180) / 100
      received_inventory.revenue = received_inventory.sold_units * item_revenue
      profit_without_fees = received_inventory.revenue - received_inventory.cost_sold
      received_inventory.fees = profit_without_fees * Faker::Number.between(20, 30) / 100
      received_inventory.save!
    end
  end

end
