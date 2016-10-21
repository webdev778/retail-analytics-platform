class DashboardController < ApplicationController
  def index
  end

  def total
    @sales_and_inv_chart = TotalChartsService.new.sales_and_inventory_turnover
    @roi_and_sell_through_chart = TotalChartsService.new.roi_and_sell_through
    @total_data = ReceivedInventory.select('SUM(cost_remain) cost_remain').order(nil).first
  end

  def total
    @roi_chart = TotalChartsService.new.sales_and_inventory_turnover
  end
end
