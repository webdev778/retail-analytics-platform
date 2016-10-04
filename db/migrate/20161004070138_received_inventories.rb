class ReceivedInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :received_inventories do |t|
      t.belongs_to :marketplace, index: true
      t.datetime :received_date
      t.string :fnsku
      t.string :sku
      t.string :product_name
      t.string :quantity
      t.string :fba_shipment_id

      t.timestamps
    end
  end
end
