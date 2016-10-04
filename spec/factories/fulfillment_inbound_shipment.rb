include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :fulfillment_inbound_shipment do
    marketplace

    shipment_id 'test'
    external_date_created { Time.zone.now }
  end
end
