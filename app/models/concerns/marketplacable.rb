module Marketplacable
  extend ActiveSupport::Concern

  included do
    belongs_to :marketplace

    scope :for_user, -> (user) do
      joins(:marketplace).where(marketplaces: { user_id: user })
    end
  end
end
