class ChangeTotalForTransactions < ActiveRecord::Migration[5.0]
  def change
    change_column :transactions, :total, :decimal, precision: 10, scale: 2, using: 'CAST(total AS integer)', default: 0
  end
end
