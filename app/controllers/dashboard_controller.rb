# frozen_string_literal: true
class DashboardController < ApplicationController
  def index
  end

  def total
    @sales_and_inv_chart = TotalChartsService.new.sales_and_inventory_turnover current_user
    @roi_and_sell_through_chart = TotalChartsService.new.roi_and_sell_through current_user
    @total_inventory_data = ReceivedInventory.select('SUM(cost_remain) cost_remain')
                                             .select_roi
                                             .select_sell_through
                                             .select_cogs_turnover_for_30_days
                                             .select_monthly_growth_rate
                                             .for_user(current_user)
                                             .active
                                             .order(nil)
                                             .first

    @total_transactions_data = Transaction.select_sales_turnover_for_30_days.for_user(current_user).order(nil).first
  end
end
