# frozen_string_literal: true
require 'rails_helper'

describe ReportParser::ReceivedInventoryParser do
  context 'parse settlement report' do
    let(:file_content) { CSV.parse(File.read(File.join(fixture_path, 'reports', 'settlement_cutted_report_data.txt')), headers: true) }

    let(:user) { create(:user) }
    let!(:account) { build(:account, user: user).save(validate: false) }
    let!(:marketplace) { create(:marketplace, user: user, account: Account.first) }
    let(:report) { create(:report, marketplace: marketplace, user: user) }

    # subject { ReportParser::SettlementParser.new(file_content, marketplace, report) }

    # product_sales: 19.99
    # fba_fees: 4.4 ! without minus
    # other_transaction_fees: 3 ! without minus

    # received_inventory.revenue: 19.99 !

    # 105-9908022-0462606
    # product_sales: 38.13
    # fba_fees: 5.18 ! without minus
    # other_transaction_fees: 5.34 ! without minus

    # received_inventory.revenue: 38.13 !
    before { subject }
  end
end
