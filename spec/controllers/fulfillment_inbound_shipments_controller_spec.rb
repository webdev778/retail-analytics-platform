# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FulfillmentInboundShipmentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:account) { build(:account, user: user).save(validate: false) }
  let!(:marketplace) { create(:marketplace, user: user, account: Account.first) }
  let(:fulfillment_inbound_shipment) { create(:fulfillment_inbound_shipment, marketplace: marketplace) }

  describe 'GET #index' do
    it 'assigns all fulfillment_inbound_shipments as @fulfillment_inbound_shipments' do
      sign_in user

      get :index
      expect(assigns(:fulfillment_inbound_shipments)).to eq([fulfillment_inbound_shipment])
    end
  end
end
