# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InventoryDataUpload, type: :model do
  it { should belong_to(:user) }
end
