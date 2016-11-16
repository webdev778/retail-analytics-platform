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
           aws_access_key_id: 'AKIAJA3HRHJWHH2CEBAQ',
           secret_key: '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',
           account: Account.first)
  end

  describe 'check_connection' do
    before do
      account
      marketplace
    end

    context 'successfully' do
      subject { MWS::ImportService.check_connection(Account.first, marketplace) }

      it 'should return true' do
        VCR.use_cassette('check_connection_successfully') do
          subject
        end
        expect(subject).to eq true
      end
    end

    context 'fail' do
      let(:account) do
        build(:account,
              user: user,
              mws_auth_token: nil).save(validate: false)
      end
      let(:marketplace) do
        create(:marketplace,
               account: Account.first)
      end
      subject { MWS::ImportService.check_connection(Account.first, marketplace) }

      it 'should return false' do
        VCR.use_cassette('check_connection_fail') do
          subject
        end
        expect(subject).to eq false
      end
    end
  end

  describe 'settlement_reports' do
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

  describe 'get_settlement_report_data' do
    before do
      Timecop.freeze(Time.local(1990))
      account
      marketplace
    end

    after do
      Timecop.return
    end

    context 'get report' do
      let(:settlement_report) do
        create(:report,
               generated_report_id: '2650479163017035',
               report_type: '_GET_V2_SETTLEMENT_REPORT_DATA_FLAT_FILE_V2_',
               marketplace: marketplace)
      end

      subject { MWS::ImportService.get_settlement_report_data(settlement_report) }

      it 'should update attribute get_data' do
        VCR.use_cassette('settlement_report_data') do
          subject
        end

        expect(settlement_report.get_data).to eq(Time.zone.now)
        # TODO: stub SettlementParser
        expect(Transaction.count).to_not eq 0
      end
    end
  end

  describe 'request_report' do
    subject { MWS::ImportService.request_report(marketplace, '_GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_') }

    before do
      account
      marketplace
    end

    it 'should return request_id' do
      VCR.use_cassette('fulfillment_inventory_report_request') do
        subject
      end

      expect(subject).to eq '168374017120'
    end
  end

  describe 'get_report_status' do
    before do
      account
      marketplace
    end

    context 'done_no_data' do
      subject { MWS::ImportService.get_report_status(marketplace, '168374017120') }

      it 'should be done_no_data' do
        VCR.use_cassette('report_status_check') do
          subject
        end
        expect(subject).to eq '_DONE_NO_DATA_'
      end
    end

    context 'done' do
      # 167557017113
      subject { MWS::ImportService.get_report_status(marketplace, '167557017113') }

      it 'should be done_no_data' do
        VCR.use_cassette('report_status_done') do
          subject
        end
        # stub get_data
        expect(subject).to eq '_DONE_'
      end
    end
  end
end
