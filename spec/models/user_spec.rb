# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:inventory_data_uploads) }
  it { should have_many(:accounts) }
  it { should have_many(:marketplaces) }

  describe 'checking users merketplaces' do
    context 'user with marketplaces' do
      let(:user) { create(:user) }

      subject { user.marketplace_connected? }

      it 'should return false' do
        expect(subject).to eq false
      end
    end

    context 'user without marketplaces' do
      let(:user) { create(:user) }
      let!(:account) { build(:account, user: user).save(validate: false) }
      let!(:marketplace) { create(:marketplace, user: user, account: Account.first) }

      subject { user.marketplace_connected? }

      it 'should return true' do
        expect(subject).to eq true
      end
    end
  end
end
