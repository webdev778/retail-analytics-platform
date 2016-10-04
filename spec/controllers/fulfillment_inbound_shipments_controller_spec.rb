require 'rails_helper'

RSpec.describe FulfillmentInboundShipmentsController, type: :controller do
  let(:user) { create(:user) }
  let(:fulfillment_inbound_shipment) { create(:fulfillment_inbound_shipment) }

  describe 'GET #index' do
    it 'assigns all fulfillment_inbound_shipments as @fulfillment_inbound_shipments' do
      sign_in user

      get :index
      expect(assigns(:fulfillment_inbound_shipments)).to eq([fulfillment_inbound_shipment])
    end
  end

end
