class Marketplace < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates_presence_of :external_marketplace_id,
                        :aws_access_key_id,
                        :secret_key

end
