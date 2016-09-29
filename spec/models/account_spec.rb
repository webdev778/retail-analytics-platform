require 'rails_helper'

RSpec.describe Account, type: :model do
  it { should belong_to(:user) }
  it { should have_one(:marketplace) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:seller_id) }
  it { should validate_uniqueness_of(:seller_id) }
end
