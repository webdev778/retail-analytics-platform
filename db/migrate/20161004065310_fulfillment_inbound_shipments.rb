class FulfillmentInboundShipments < ActiveRecord::Migration[5.0]
  def change
    create_table :fulfillment_inbound_shipments do |t|
      t.belongs_to :marketplace, index: true
      t.string :shipment_id
      t.datetime :external_date_created
      t.decimal :price, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
