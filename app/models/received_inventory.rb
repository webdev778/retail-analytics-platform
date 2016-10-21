class ReceivedInventory < ApplicationRecord
  belongs_to :marketplace

  scope :active, -> { where('quantity > 0') }
end
