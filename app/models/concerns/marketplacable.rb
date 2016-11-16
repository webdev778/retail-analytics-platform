# frozen_string_literal: true
module Marketplacable
  extend ActiveSupport::Concern

  included do
    belongs_to :marketplace

    scope :for_user, -> (user) { joins(:marketplace).where(marketplaces: { user_id: user }) }
  end
end
