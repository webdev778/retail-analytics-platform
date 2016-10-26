class ReceivedInventory < ApplicationRecord
  belongs_to :marketplace

  scope :positive_quantity, -> { where('quantity > 0') }
  # scope :sold, -> { where('quantity = sold_units') }
  scope :sold, -> { where('quantity = sold_units') }
  scope :with_unsold, -> { where('quantity > sold_units AND quantity > 0') }
end
