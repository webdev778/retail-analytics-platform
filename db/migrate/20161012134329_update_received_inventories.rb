class UpdateReceivedInventories < ActiveRecord::Migration[5.0]
  def change
    add_column :received_inventories, :sold_date, :datetime
    add_column :received_inventories, :sold_units, :integer
    add_column :received_inventories, :cost_sold, :decimal, precision: 10, scale: 2, default: 0
    add_column :received_inventories, :remain_units, :integer
    add_column :received_inventories, :cost_remain, :decimal, precision: 10, scale: 2, default: 0
  end
end
