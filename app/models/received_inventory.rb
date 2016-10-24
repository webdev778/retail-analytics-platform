class ReceivedInventory < ApplicationRecord
  belongs_to :marketplace

  scope :active, -> { where('quantity > 0') }
  scope :select_roi, -> { select('SUM(revenue - fees - cost_sold)/NULLIF(SUM(cost_sold), 0)*100 roi') }
  scope :select_sell_through, -> { select('SUM(sold_units::float)/SUM(quantity::float)*100 sell_through') }
  scope :avg_cost_remain_for_30_days, -> do
    select('AVG(cost_remain) cost_remain')
        .where('received_date > NOW() - interval \'30\' day')
        .active
  end
  scope :select_cogs_turnover, -> do
    select("SUM(cost_sold)/(#{ReceivedInventory.except(:select).avg_cost_remain_for_30_days.to_sql}) cogs_turnover")
  end
  scope :inventory_cost_30_days_old, -> do
    select('COALESCE(SUM(price_total), 0) inventory_cost_30_days_old')
        .where('received_date < NOW() - interval \'30\' day')
        .active
  end
  scope :select_monthly_growth_rate, -> do
    old_inventory_cost = ReceivedInventory.except(:select).inventory_cost_30_days_old.to_sql
    select "SUM(price_total) - (#{old_inventory_cost}) monthly_growth_rate"
  end
end
