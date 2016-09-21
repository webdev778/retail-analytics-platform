class Account < ApplicationRecord
  belongs_to :user
  has_one :marketplace

  validates_presence_of :user,
                        :seller_id,
                        :mws_auth_token

  validates_uniqueness_of :seller_id
end
