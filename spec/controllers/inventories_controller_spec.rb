require 'rails_helper'

RSpec.describe InventoriesController, type: :controller do
  describe 'GET #index' do
    it 'allows authenticated access' do
      sign_in
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET #new' do
    it 'allows authenticated access' do
      sign_in
      get :new
      expect(response).to be_success
    end
  end
end
