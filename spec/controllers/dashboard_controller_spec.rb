# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #index' do
    it 'blocks unauthenticated access' do
      sign_in nil
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows authenticated access' do
      sign_in user
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET #total' do
    it 'dashboard total' do
      sign_in user
      get :total
      expect(response).to be_success
    end
  end
end
