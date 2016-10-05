class FulfillmentInboundShipmentsController < ApplicationController
  before_action :set_fulfillment_inbound_shipment, only: [:show, :edit, :update, :destroy]

  # GET /fulfillment_inbound_shipments
  def index
    @fulfillment_inbound_shipments = FulfillmentInboundShipment.page params[:page]
  end
end
