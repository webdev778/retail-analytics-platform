class AddAdditionalFields < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :price_per_unit, :decimal, precision: 10, scale: 2, default: 0
    add_column :received_inventories, :price_total, :decimal, precision: 10, scale: 2, default: 0
    add_column :fulfillment_inbound_shipments, :total_received_units, :integer, after: :price
  end
end
