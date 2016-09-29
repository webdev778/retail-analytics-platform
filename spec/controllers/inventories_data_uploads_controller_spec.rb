require 'rails_helper'

RSpec.describe InventoriesDataUploadsController, type: :controller do
  let(:user) { create(:user) }
  let(:inventory_data_upload) { create(:csv, user: user) }

  describe 'GET #new' do
    before { inventory_data_upload }

    it 'allows authenticated access' do
      sign_in user
      get :new
      expect(response).to be_success
      expect(assigns(:inventory_data_uploads)).to eq([inventory_data_upload])
    end
  end

  describe 'POST #create' do
    it 'allows authenticated access' do
      sign_in user
      file = fixture_file_upload('/files/Inventory_Upload.csv', 'text/plain')
      post :create, params: { inventory_data_upload: { file_for_import: file } }
      expect(InventoryDataUpload.count).to eq 1
    end
  end
end
