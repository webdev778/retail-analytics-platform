# frozen_string_literal: true
class FulfillmentInboundShipment < ApplicationRecord
  belongs_to :marketplace
  has_many :received_inventories, primary_key: :shipment_id, foreign_key: :fba_shipment_id

  scope :select_days_to_breakeven, -> do
    select 'DATE_PART(\'day\', breakeven_date - external_date_created) days_to_breakeven'
  end
end
