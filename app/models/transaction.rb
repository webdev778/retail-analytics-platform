class Transaction < ApplicationRecord
  belongs_to :marketplace

  belongs_to :report

  scope :type_order, -> { where(transaction_type: 'Order') }

  scope :select_sales_turnover, -> do
    select("SUM(quantity)/(#{ReceivedInventory.avg_cost_remain_for_30_days.to_sql}) sales_turnover")
  end
end
