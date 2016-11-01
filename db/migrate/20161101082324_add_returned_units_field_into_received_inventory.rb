class AddReturnedUnitsFieldIntoReceivedInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :returned_units, :integer, default: 0
  end
end
