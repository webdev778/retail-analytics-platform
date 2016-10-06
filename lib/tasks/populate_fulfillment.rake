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
end
