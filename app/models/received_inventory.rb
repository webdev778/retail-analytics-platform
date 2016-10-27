class ReceivedInventory < ApplicationRecord
  belongs_to :marketplace

  scope :positive_quantity, -> { where('quantity > 0') }
  scope :sold, -> { where('quantity = sold_units') }
  scope :with_unsold, -> { where('quantity > sold_units AND quantity > 0') }
  scope :active, -> { where('quantity > 0') }
  scope :select_roi, -> { select('SUM(revenue - fees - cost_sold)/NULLIF(SUM(cost_sold), 0)*100 roi') }
  scope :select_prev_roi, -> do
    select('SUM(SUM(revenue) - SUM(fees) - SUM(cost_sold)) OVER (ORDER BY MAX(received_date))/
            NULLIF(SUM(SUM(cost_sold)) OVER (ORDER BY MAX(received_date)), 0)*100 roi')
  end
  scope :select_sell_through, -> { select('SUM(sold_units::float)/SUM(quantity::float)*100 sell_through') }
  scope :select_prev_sell_through, -> do
    select('SUM(SUM(sold_units::float)) OVER (ORDER BY MAX(received_date))/
            SUM(SUM(quantity::float)) OVER (ORDER BY MAX(received_date))*100 sell_through')
  end
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
