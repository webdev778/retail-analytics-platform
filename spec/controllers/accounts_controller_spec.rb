# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:user) { create(:user) }
  let(:account_skip_validation) { build(:account, user: user).save(validate: false) }

  before { sign_in user }

  describe 'GET #index' do
    before do
      user
      account_skip_validation
    end

    it 'returns an array of accounts' do
      get :index
      account = Account.first
      expect(assigns(:accounts)).to eq([account])
    end
  end

  describe 'GET #new' do
    it 'build new marketplace' do
      get :new
      expect(assigns(:account).marketplace).to be_a_new(Marketplace)
    end
  end

  describe 'POST #create' do
    let(:marketplace_params) { { marketplace_attributes: attributes_for(:marketplace) } }
    let(:account_params) { { account: attributes_for(:account).merge(marketplace_params) } }

    subject { post :create, params: account_params }

    context 'success' do
      before do
        allow_any_instance_of(Account).to receive(:check_connection)
        allow(controller).to receive_messages(current_user: user)
        allow(MWS::ImportService).to receive(:initial_import).and_return(true)
      end

      it 'should create account and marketplace' do
        expect(subject).to redirect_to(accounts_path)
        expect(Account.count).to eq 1
        expect(Marketplace.count).to eq 1
        expect(flash[:notice]).to eq('Account was successfully added')
      end
    end

    context 'fail' do
      it 'should render new' do
        expect(subject).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { account_skip_validation }

    subject { delete :destroy, params: { id: Account.first } }

    it 'should delete' do
      expect(subject).to redirect_to(accounts_path)
      expect(Account.count).to eq 0
    end
  end
end
