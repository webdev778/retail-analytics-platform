class AddPriceToReceivedInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :price_per_unit, :decimal, precision: 10, scale: 2
    add_column :received_inventories, :price_total, :decimal, precision: 10, scale: 2
  end
end
