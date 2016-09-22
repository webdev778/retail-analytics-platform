require 'rails_helper'

RSpec.describe Marketplace, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:account) }
  it { should validate_presence_of(:external_marketplace_id) }
  it { should validate_presence_of(:aws_access_key_id) }
  it { should validate_presence_of(:secret_key) }
end
