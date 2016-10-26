# frozen_string_literal: true
require 'rails_helper'

describe MWS::ImportService do
  let(:user) { create(:user) }
  let(:account) do
    build(:account,
          user: user,
          seller_id: 'A1HRWKXDFQTX7Z',
          mws_auth_token: nil).save(validate: false)
  end
  let(:marketplace) do
    create(:marketplace,
           external_marketplace_id: 'ATVPDKIKX0DER',
           account: Account.first)
  end

  subject { MWS::ImportService.get_settlement_reports_info(marketplace) }

  before do
    account
    marketplace
  end

  it 'should fill transactions' do
    VCR.use_cassette('done_settlements') do
      subject
    end

    expect(Report.count).to eq 6

    VCR.use_cassette('settlement_report') do
      MWS::ImportService.get_settlement_report_data(Report.first)
    end

    expect(Transaction.count).to_not eq 0
  end
end
