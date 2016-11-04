# frozen_string_literal: true
class DashboardController < ApplicationController
  def index
  end

  def total
    @sales_and_inv_chart = TotalChartsService.new.sales_and_inventory_turnover
    @roi_and_sell_through_chart = TotalChartsService.new.roi_and_sell_through
    @total_inventory_data = ReceivedInventory.select('SUM(cost_remain) cost_remain')
                                             .select_roi
                                             .select_sell_through
                                             .select_cogs_turnover_for_30_days
                                             .select_monthly_growth_rate
                                             .active
                                             .order(nil)
                                             .first

    @total_transactions_data = Transaction.select_sales_turnover_for_30_days.order(nil).first
  end
end
