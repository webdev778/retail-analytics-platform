# frozen_string_literal: true
require 'rails_helper'

describe ReportParser::ParseService do
  let(:user) { create(:user) }

  let(:account_skip_validation) { build(:account, user: user, seller_id: '').save(validate: false) }
  let(:marketplace) do
    create(:marketplace,
           account: Account.first,
           external_marketplace_id: '',
           aws_access_key_id: '',
           secret_key: '')
  end

  before do
    account_skip_validation
    marketplace
  end

  subject do
    # ReportParser::ParseService.new()
  end

  xit '' do
    VCR.use_cassette('fba_fullfillment_inventory_receipts_data') do
      subject
    end
    # response = connect!(marketplace).get_report(id)
    # response = response.parse
    # ReportParser::ParseService.new(response, report_type, marketplace)
    # _GET_FBA_FULFILLMENT_INVENTORY_RECEIPTS_DATA_
    # 3115181039017090
  end
end
