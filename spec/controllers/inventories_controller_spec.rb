# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InventoriesController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:account_skip_validation) { build(:account, user: user, marketplace: marketplace).save(validate: false) }
    let(:marketplace) { create(:marketplace, user: user) }
    let(:received_inventory) { create(:received_inventory, marketplace: Marketplace.first) }

    before do
      user
      account_skip_validation
      received_inventory
      sign_in user
      allow(controller).to receive_messages(current_user: user)
    end

    it 'returns an array of received_inventories' do
      get :index
      expect(assigns(:received_inventories)).to eq([received_inventory])
    end
  end
end
