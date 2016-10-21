class AddSoldTotalToReceivedInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :revenue, :decimal, precision: 10, scale: 2
    add_column :received_inventories, :fees, :decimal, precision: 10, scale: 2
  end
end
