class ChangeQuantityInTransactions < ActiveRecord::Migration[5.0]
  def change
    change_column :transactions, :quantity, :decimal, precision: 10, scale: 2, using: 'CAST(total AS integer)'
  end
end
