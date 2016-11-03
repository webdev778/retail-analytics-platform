class RemoveOtherFromTransactions < ActiveRecord::Migration[5.0]
  def change
    remove_column :transactions, :other
  end
end
