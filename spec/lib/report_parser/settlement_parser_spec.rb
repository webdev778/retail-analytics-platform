# frozen_string_literal: true
require 'rails_helper'

describe ReportParser::SettlementParser do
  context 'parse settlement report' do
    let(:file_content) { CSV.parse(File.read(File.join(fixture_path, 'reports', 'settlement_cutted_report_data.txt')), headers: true) }

    let(:user) { create(:user) }
    let!(:account) { build(:account, user: user).save(validate: false) }
    let!(:marketplace) { create(:marketplace, user: user, account: Account.first) }
    let(:report) { create(:report, marketplace: marketplace, user: user) }

    subject { ReportParser::SettlementParser.new(file_content, marketplace, report) }

    before { subject }

    it 'should be 4 Transactions' do
      expect(Transaction.count).to eq 5
    end

    it 'check transaction values for order 112-2337018-9206664' do
      transaction = Transaction.find_by_external_order_id('112-2337018-9206664')

      expect(transaction.product_sales.to_s).to eq '19.99'
      expect(transaction.fba_fees.to_s).to eq '4.4'
      expect(transaction.other_transaction_fees.to_s).to eq '3.0'

      expect(transaction.shipping_credits.to_s).to eq '0.0'
      expect(transaction.gift_wrap_credits.to_s).to eq '0.0'
      expect(transaction.selling_fees.to_s).to eq '0.0'
      expect(transaction.total.to_s).to eq '12.59'
    end

    it 'check transaction values for order 105-9908022-0462606' do
      transaction = Transaction.find_by_external_order_id('105-9908022-0462606')

      expect(transaction.product_sales.to_s).to eq '38.13'
      expect(transaction.fba_fees.to_s).to eq '5.18'
      expect(transaction.other_transaction_fees.to_s).to eq '5.34'

      expect(transaction.shipping_credits.to_s).to eq '0.0'
      expect(transaction.gift_wrap_credits.to_s).to eq '0.0'
      expect(transaction.selling_fees.to_s).to eq '0.09'
      expect(transaction.total.to_s).to eq '27.61'
    end

    it 'check shipping_credits' do
      transaction = Transaction.find_by_external_order_id('116-1201758-6837009')

      expect(transaction.shipping_credits.to_s).to eq '5.48'
    end

    it 'check gift_wrap_credits' do
      transaction = Transaction.find_by_external_order_id('002-3918038-0114658')

      expect(transaction.gift_wrap_credits.to_s).to eq '3.49'
    end
  end
end
