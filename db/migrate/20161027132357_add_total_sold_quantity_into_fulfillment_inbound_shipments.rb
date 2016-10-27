class AddTotalSoldQuantityIntoFulfillmentInboundShipments < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillment_inbound_shipments, :total_sold, :integer, default: 0
    add_column :fulfillment_inbound_shipments, :total_revenue, :decimal, precision: 10, scale: 2, default: 0
  end
end
