class Transactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.belongs_to :marketplace, index: true
      t.belongs_to :report, index: true

      t.datetime :date_time
      t.string :settlement_id
      t.string :transaction_type
      t.string :external_order_id
      t.string :sku
      t.integer :quantity
      t.string :product_sales
      t.string :shipping_credits
      t.string :gift_wrap_credits
      t.string :promotional_rebates
      t.string :selling_fees
      t.string :fba_fees
      t.string :other_transaction_fees
      t.string :other
      t.string :total

      t.decimal :shipping_price, precision: 10, scale: 2
      t.decimal :shipping_tax, precision: 10, scale: 2
      t.decimal :item_promotion_discount, precision: 10, scale: 2
      t.decimal :ship_promotion_discount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
