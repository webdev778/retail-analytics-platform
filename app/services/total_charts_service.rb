class TotalChartsService
  def sales_and_inventory_turnover
    charts_data = sales_and_inventory_data

    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: I18n.t('charts.sales_and_inventory_turnover.title'))
      f.xAxis(
          type: :datetime,
          title: '',
          labels: { format: '{value:%d %b %Y}', rotation: -45, align: 'right' },
          tickInterval: 24 * 3600 * 1000
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
      f.chart(type: 'line')
    end
  end

  private

  def sales_and_inventory_data
    data = Transaction.group_by_day(:date_time)
               .select('MIN(date_time) date_time')
               .select('SUM(total) total')
               .select("SUM(total)/(#{avg_cost_remain_for_30_days.to_sql}) turnover")
               .order('MIN(date_time)')
    sales_series_data = []
    turnover_series_data = []
    data.each do |grouped|
      sales_series_data.push [grouped.date_time.to_datetime.to_i * 1000, grouped.total.to_f]
      turnover_series_data.push [grouped.date_time.to_datetime.to_i * 1000, grouped.turnover.to_f]
    end
    { sales_series_data: sales_series_data, turnover_series_data: turnover_series_data }
  end

  def avg_cost_remain_for_30_days
    ReceivedInventory.select('AVG(cost_remain) cost_remain')
        .where('received_date > received_date - interval \'30\' day')
  end

end
