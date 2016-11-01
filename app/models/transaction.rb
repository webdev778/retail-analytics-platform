# frozen_string_literal: true
class Transaction < ApplicationRecord
  belongs_to :marketplace
  belongs_to :report

  scope :type_order, -> { where(transaction_type: 'Order') }
  scope :type_refund, -> { where(transaction_type: 'Refund') }
  scope :select_sales_turnover, -> do
    select("SUM(quantity)/(#{ReceivedInventory.avg_cost_remain_for_30_days.to_sql}) sales_turnover")
  end
  # division by zero
end
