class TotalChartsService
  def sales_and_inventory_turnover
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: 'Sales')
      f.xAxis(
          type: :datetime,
          title: '',
          labels: { format: '{value:%d %b %Y}', rotation: -45, align: 'right' },
          tickInterval: 24 * 3600 * 1000
      )
      f.series name: 'Sales', yAxis: 0, data: sales_series_data, color: '#e8803b', lineWidth: 5
      f.plotOptions line: { marker: { enabled: false } }
      f.yAxis [{ title: { text: 'Sales' }, labels: { format: '${value:,.2f}' } }]

      f.legend(borderColor: nil)
      f.chart({type: 'line'})
    end
  end

  private

  def sales_series_data
    transactions = Transaction.group_by_day(:date_time).sum(:total)

    transactions.map do |grouped|
      [grouped[0].to_datetime.to_i * 1000, grouped[1].to_f]
    end
  end
end
