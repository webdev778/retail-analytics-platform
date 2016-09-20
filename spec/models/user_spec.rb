require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:inventory_data_uploads) }
end
