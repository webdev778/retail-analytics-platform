class Marketplace < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_many :transactions
  has_many :received_inventories
  has_many :fulfillment_inbound_shipmants

  validates_presence_of :external_marketplace_id,
                        :aws_access_key_id,
                        :secret_key

end
