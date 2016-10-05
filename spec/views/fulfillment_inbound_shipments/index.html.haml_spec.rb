require 'rails_helper'

RSpec.describe 'fulfillment_inbound_shipments/index', type: :view do
  let(:fulfillment_inbound_shipment) { create(:fulfillment_inbound_shipment) }

  before(:each) do
    assign(:fulfillment_inbound_shipments, Kaminari.paginate_array([fulfillment_inbound_shipment]).page(1))
  end

  it 'renders a list of fulfillment_inbound_shipments' do
    render
    expect(rendered).to include(fulfillment_inbound_shipment.shipment_id)
  end
end
