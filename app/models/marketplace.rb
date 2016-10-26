class Marketplace < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_many :transactions, dependent: :destroy
  has_many :received_inventories, dependent: :destroy
  has_many :fulfillment_inbound_shipments, dependent: :destroy
  has_many :reports, dependent: :destroy

  validates_presence_of :external_marketplace_id,
                        :aws_access_key_id,
                        :secret_key
end
