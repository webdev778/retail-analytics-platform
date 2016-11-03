# frozen_string_literal: true
module ReportParser
  class SettlementParser
    def initialize(data, marketplace, report)
      @data = data
      @marketplace = marketplace
      @report = report
      settlement_report
    end

    private

    def settlement_report
      orders = {}
      @data.each do |line|
        next unless line['order-id'].present?
        orders[line['order-id']] = [] unless orders.key?(line['order-id'])
        orders[line['order-id']].append(settlement_report_params(line))
      end
      settlement_total_data(orders)
    end

    def settlement_total_data(orders)
      orders.each do |_key, value|
        order = nil
        value.each_with_index do |item, index|
          if index.zero?
            order = item
          else
            order[:transaction_type] = item[:transaction_type] unless order[:transaction_type] == 'Refund'
            order[:product_sales] = work_with_value(order, item, 'product_sales')
            order[:shipping_credits] = work_with_value(order, item, 'shipping_credits')
            order[:gift_wrap_credits] = work_with_value(order, item, 'gift_wrap_credits')
            order[:selling_fees] = work_with_value(order, item, 'selling_fees')
            order[:fba_fees] = work_with_value(order, item, 'fba_fees')
            order[:other_transaction_fees] = work_with_value(order, item, 'other_transaction_fees')
            order[:total] = work_with_value(order, item, 'total')
          end
        end
        order[:marketplace].transactions.find_or_create_by(order)
      end
    end

    def work_with_value(order, item, key)
      key = key.to_sym
      item[key] = 0 if item[key].nil?
      value_for_return = if order[key].present?
                           order[key].to_f + item[key].to_f
                         else
                           item[key]
                         end

      value_for_return
    end

    def settlement_report_params(file_line)
      product_sales_amount = file_line['amount-type'] == 'ItemPrice' ? file_line['amount'] : 0
      shipping_credits_amount = find_value(file_line, 'Shipping')
      gift_wrap_credits_amount = find_value(file_line, 'GiftWrap')
      sales_tax_service_fee = find_value(file_line, 'SalesTaxServiceFee')
      fba_fees_amount = find_value(file_line, 'FBA', 'include')
      other_transaction_fees_amount = find_value(file_line, 'FBA', 'exclude') if file_line['amount-type'] == 'ItemFees'

      other_transaction_fees_amount ||= 0
      {
        report: @report,
        date_time: file_line['posted-date-time'],
        settlement_id: file_line['settlement-id'],
        transaction_type: file_line['transaction-type'],
        external_order_id: file_line['order-id'],
        sku: file_line['sku'],
        quantity: file_line['quantity-purchased'],
        marketplace: @marketplace,
        product_sales: product_sales_amount,
        shipping_credits: shipping_credits_amount,
        gift_wrap_credits: gift_wrap_credits_amount,
        # promotional_rebates:
        selling_fees: sales_tax_service_fee,
        fba_fees: fba_fees_amount,
        other_transaction_fees: other_transaction_fees_amount,
        total: file_line['amount']
      }
    end

    def find_value(filled_object, value_of_key, include_check = nil)
      case include_check
      when 'include'
        filled_object['amount-description'] =~ /^FBA/ ? filled_object['amount'].to_f.abs : 0
      when 'exclude'
        filled_object['amount-description'] =~ /^FBA/ ? 0 : filled_object['amount'].to_f.abs
      else
        filled_object['amount-description'] == value_of_key ? filled_object['amount'].to_f.abs : 0
      end
    end
  end
end
