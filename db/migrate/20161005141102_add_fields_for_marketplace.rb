class AddFieldsForMarketplace < ActiveRecord::Migration[5.0]
  def change
    add_column :marketplaces, :get_received_inventory_finished, :datetime
  end
end
