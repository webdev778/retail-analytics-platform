class ChangeTotalForTransactions < ActiveRecord::Migration[5.0]
  def change
    change_column :transactions, :total, :decimal, precision: 10, scale: 2, using: 'CAST(total AS numeric(10,2))', default: 0
  end
end
