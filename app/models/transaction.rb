# frozen_string_literal: true
class Transaction < ApplicationRecord
  include Marketplacable

  belongs_to :report

  scope :type_order, -> { where(transaction_type: 'Order') }
  scope :type_refund, -> { where(transaction_type: 'Refund') }
  scope :select_sales_turnover_for_30_days, lambda {
    select("SUM(quantity)/NULLIF((#{ReceivedInventory.avg_cost_remain_for_30_days.to_sql}), 0) sales_turnover")
  }
end
