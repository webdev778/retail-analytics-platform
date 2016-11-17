class AddLastReceivedInventoryDate < ActiveRecord::Migration[5.0]
  def change
    add_column :marketplaces, :last_received_inventory_date, :datetime
    add_column :marketplaces, :initial_import, :boolean
  end
end
