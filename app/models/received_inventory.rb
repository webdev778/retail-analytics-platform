# frozen_string_literal: true
class ReceivedInventory < ApplicationRecord
  belongs_to :marketplace

  validates_uniqueness_of :fnsku, scope: [:sku, :product_name, :quantity, :fba_shipment_id, :received_date]

  scope :positive_quantity, -> { where('quantity > 0') }
  scope :sold, -> { where('quantity = sold_units') }
  scope :with_unsold, -> { where('quantity > sold_units AND quantity > 0') }
  scope :active, -> { where('quantity > 0') }
  scope :select_roi, -> { select('SUM(revenue - fees - cost_sold)/NULLIF(SUM(cost_sold), 0)*100 roi') }
  scope :select_profit, -> { select('SUM(revenue - fees - cost_sold) profit') }
  scope :select_avg_purchase, -> { select('SUM(price_total)/SUM(quantity::float) avg_purchase') }
  scope :select_avg_revenue, -> { select('SUM(revenue)/SUM(quantity::float) avg_revenue') }
  scope :select_avg_profit, -> { select('SUM(revenue - fees - cost_sold)/SUM(quantity::float) avg_profit') }
  scope :select_avg_inventory_age, -> do
    select('AVG(DATE_PART(\'day\', sold_date - received_date)) avg_inventory_age')
  end
  scope :select_prev_roi, -> do
    select('SUM(SUM(revenue) - SUM(fees) - SUM(cost_sold)) OVER (ORDER BY MAX(received_date))/
            NULLIF(SUM(SUM(cost_sold)) OVER (ORDER BY MAX(received_date)), 0)*100 roi')
  end
  scope :select_sell_through, -> { select('SUM(sold_units::float)/NULLIF(SUM(quantity::float), 0)*100 sell_through') }
  scope :select_prev_sell_through, -> do
    select('SUM(SUM(sold_units::float)) OVER (ORDER BY MAX(received_date))/
            SUM(SUM(quantity::float)) OVER (ORDER BY MAX(received_date))*100 sell_through')
  end
  scope :avg_cost_remain_for_30_days, -> do
    select('AVG(cost_remain) cost_remain')
      .where('received_date > NOW() - interval \'30\' day')
      .active
  end
  scope :select_cogs_turnover_for_30_days, -> do
    select("SUM(cost_sold)/NULLIF((#{ReceivedInventory.except(:select).avg_cost_remain_for_30_days.to_sql}), 0) cogs_turnover")
  end
  scope :select_sells_turnover, -> do
    select('SUM(revenue)/SUM(price_total) sells_turnover')
  end
  scope :select_cogs_turnover, -> do
    select('SUM(cost_sold)/SUM(price_total) cogs_turnover')
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
