# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReceivedInventory, type: :model do
  it { should belong_to(:marketplace) }
end
