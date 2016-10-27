class AddDefaultZeroForSoldUnits < ActiveRecord::Migration[5.0]
  def change
    change_column :received_inventories, :sold_units, :integer, default: 0
    change_column :received_inventories, :remain_units, :integer, default: 0
  end
end
