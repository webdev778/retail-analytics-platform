class TotalChartsService
  def sales_and_inventory_turnover
    charts_data = sales_and_inventory_data

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: I18n.t('charts.sales_and_inventory_turnover.title'))
      f.xAxis(
          type: :datetime,
          title: '',
          labels: { format: '{value:%b %Y}', rotation: -45, align: 'right' },
          tickInterval: 24 * 3600 * 30 * 1000
      )
      f.series(name: I18n.t('charts.sales_and_inventory_turnover.sales'), yAxis: 0,
               data: charts_data[:sales_series_data], color: '#e8803b', lineWidth: 5)
      f.series(name: I18n.t('charts.sales_and_inventory_turnover.inv'), yAxis: 1,
               data: charts_data[:turnover_series_data], color: '#5797d4', lineWidth: 5)
      f.plotOptions line: { marker: { enabled: false } }
      f.yAxis [
                  {
                      title: { text: I18n.t('charts.sales_and_inventory_turnover.sales') },
                      labels: { format: '${value:,.2f}' }
                  },
                  {
                      title: { text: I18n.t('charts.sales_and_inventory_turnover.inv') },
                      labels: { format: '{value:,.2f}' }, opposite: true
                  }
              ]
      f.legend(borderColor: nil)
      f.tooltip pointFormat: '{series.name}: <b>{point.y:,.2f}</b>'
      f.chart(type: 'line')
    end
  end

  def roi_and_sell_through
    charts_data = roi_and_sell_through_data

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: I18n.t('charts.roi_and_sell_through.title'))
      f.xAxis(
          type: :category,
          title: '',
          labels: { rotation: -45, align: 'right' }
      )
      f.series(name: I18n.t('charts.roi_and_sell_through.roi'), yAxis: 0,
               data: charts_data[:roi], color: '#e8803b', lineWidth: 5)
      f.series(name: I18n.t('charts.roi_and_sell_through.sell_through'), yAxis: 0,
               data: charts_data[:sell_through], color: '#5797d4', lineWidth: 5)
      f.plotOptions line: { marker: { enabled: false } }
      f.yAxis [
                  {
                      min: 0,
                      max: 100,
                      tickInterval: 20,
                      labels: { format: '{value:,.0f} %' }
                  }
              ]
      f.legend(borderColor: nil)
      f.tooltip pointFormat: '{series.name}: <b>{point.y:,.2f}</b>'
      f.chart(type: 'line')
    end
  end

  private

  def sales_and_inventory_data
    data = Transaction.group_by_day(:date_time)
               .select('MIN(date_time) date_time')
               .select('SUM(total) total')
               .select_sales_turnover_for_30_days
               .order('MIN(date_time)')
    sales_series_data = []
    turnover_series_data = []
    data.each do |grouped|
      sales_series_data.push [grouped.date_time.to_datetime.to_i * 1000, grouped.total.to_f]
      turnover_series_data.push [grouped.date_time.to_datetime.to_i * 1000, grouped.sales_turnover.to_f]
    end
    { sales_series_data: sales_series_data, turnover_series_data: turnover_series_data }
  end

  def roi_and_sell_through_data
    data = ReceivedInventory.select("DATE_PART('day', COALESCE(sold_date, now()) - received_date) age")
               .select_prev_roi
               .select_prev_sell_through
               .active
               .group(:age)
               .order('1')
    roi_data = []
    sell_through_data = []
    data.each do |grouped|
      roi_data.push [grouped.age, grouped.roi.to_f]
      sell_through_data.push [grouped.age, grouped.sell_through.to_f]
    end
    { roi: roi_data, sell_through: sell_through_data }
  end

end
