# frozen_string_literal: true
class Inventory < ApplicationRecord
  validates :msku, :price, presence: true
  validates_uniqueness_of :msku, scope: [:price, :date_purchased]

  default_scope { order(created_at: :desc) }

  belongs_to :user
end
