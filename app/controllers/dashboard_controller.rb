class DashboardController < ApplicationController
  def index
  end

  def total
    @sales_and_inv_chart = TotalChartsService.new.sales_and_inventory_turnover
    @total_data = ReceivedInventory.select('SUM(cost_remain) cost_remain').order(nil).first
  end
end
