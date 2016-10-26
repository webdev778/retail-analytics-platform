class AdditionalFieldForTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :unprocessed_quantity, :integer
  end
end
