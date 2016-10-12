require 'rails_helper'

RSpec.describe Inventory, type: :model do
  it { should validate_presence_of(:msku) }
  it { should validate_presence_of(:price) }
  it { should validate_uniqueness_of(:msku).scoped_to([:price, :date_purchased]) }
end
