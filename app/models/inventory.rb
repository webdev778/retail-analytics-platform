class Inventory < ApplicationRecord
  validates :msku, :price, :date_purchased, presence: true
  validates_uniqueness_of :msku, scope: [:price, :date_purchased]
end