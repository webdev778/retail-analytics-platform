class ChangeFieldTypes < ActiveRecord::Migration[5.0]
  def change
    change_column :transactions, :product_sales, :decimal, precision: 10, scale: 2, using: 'CAST(product_sales AS numeric(10,2))', default: 0
    change_column :transactions, :shipping_credits, :decimal, precision: 10, scale: 2, using: 'CAST(shipping_credits AS numeric(10,2))', default: 0
    change_column :transactions, :gift_wrap_credits, :decimal, precision: 10, scale: 2, using: 'CAST(gift_wrap_credits AS numeric(10,2))', default: 0
    change_column :transactions, :promotional_rebates, :decimal, precision: 10, scale: 2, using: 'CAST(promotional_rebates AS numeric(10,2))', default: 0
    change_column :transactions, :other, :decimal, precision: 10, scale: 2, using: 'CAST(total AS numeric(10,2))', default: 0
  end
end
