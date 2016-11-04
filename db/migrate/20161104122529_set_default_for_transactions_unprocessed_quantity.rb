class SetDefaultForTransactionsUnprocessedQuantity < ActiveRecord::Migration[5.0]
  def change
    change_column_default :transactions, :unprocessed_quantity, 0
  end
end
