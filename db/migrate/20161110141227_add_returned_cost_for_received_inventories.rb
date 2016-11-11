class AddReturnedCostForReceivedInventories < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :returned_cost, :decimal, precision: 10, scale: 2, default: 0
  end
end
