class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.belongs_to :user, index: true
      t.string :msku
      t.decimal :price, precision: 10, scale: 2
      t.date :date_purchased

      t.timestamps null: false
    end
  end
end
