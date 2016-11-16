# frozen_string_literal: true
class FulfillmentInboundShipment < ApplicationRecord
  include Marketplacable

  has_many :received_inventories, primary_key: :shipment_id, foreign_key: :fba_shipment_id

  scope :select_days_to_breakeven, lambda {
    select 'DATE_PART(\'day\', breakeven_date - external_date_created) days_to_breakeven'
  }
end
