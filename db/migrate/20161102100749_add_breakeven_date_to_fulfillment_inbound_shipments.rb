class AddBreakevenDateToFulfillmentInboundShipments < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillment_inbound_shipments, :breakeven_date, :datetime, null: true
  end
end
