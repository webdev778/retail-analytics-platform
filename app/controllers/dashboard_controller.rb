class DashboardController < ApplicationController
  def index
  end

  def total
    @roi_chart = TotalChartsService.new.sales_and_inventory_turnover
  end
end
