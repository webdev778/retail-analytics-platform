class AddTotalSoldQuantityIntoFulfillmentInboundShipments < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillment_inbound_shipments, :total_sold, :integer, default: 0
  end
end
