require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index' do
    context 'when not authenticated' do
      it 'should redirect' do
        get :index
        expect(response).to have_http_status(302)
      end
    end

    context 'when authenticated' do

    end
  end
end
