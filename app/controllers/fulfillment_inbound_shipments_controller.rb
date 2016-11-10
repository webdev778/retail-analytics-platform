# frozen_string_literal: true
class FulfillmentInboundShipmentsController < ApplicationController
  before_action :set_shipment, only: [:edit, :update, :destroy]

  # GET /fulfillment_inbound_shipments
  def index
    @fulfillment_inbound_shipments = FulfillmentInboundShipment.for_user(current_user).page params[:page]
  end

  def show
    @shipment = FulfillmentInboundShipment.select('*')
                    .select_days_to_breakeven
                    .for_user(current_user)
                    .find params[:id]

    @summary = @shipment.received_inventories
        .select('SUM(quantity) quantity')
        .select('SUM(cost_sold) cost_sold')
        .select('SUM(price_total) price_total')
        .select('SUM(sold_units) sold_units')
        .select('SUM(revenue) revenue')
        .select('SUM(fees) fees')
        .select('SUM(cost_remain) cost_remain')
        .select('SUM(remain_units) remain_units')
        .select_return_rate
        .select_roi
        .select_profit
        .select_avg_purchase
        .select_avg_revenue
        .select_avg_profit
        .select_avg_inventory_age
        .select_sell_through
        .select_sells_turnover
        .select_cogs_turnover
        .active
        .take
  end

  private

  def set_shipment
    @shipment = FulfillmentInboundShipment.find params[:id]
  end
end
