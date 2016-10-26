class Transaction < ApplicationRecord
  belongs_to :marketplace

  belongs_to :report

  scope :type_order, -> { where(transaction_type: 'Order') }
end
