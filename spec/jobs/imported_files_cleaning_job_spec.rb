# frozen_string_literal: true
require 'rails_helper'
RSpec.describe ImportedFilesCleaningJob, type: :job do
  let(:user) { create(:user) }
  let(:csv) { create(:csv, user: user, created_at: 6.month.ago) }
  let(:finished_csv1) { create(:finished_csv, user: user, created_at: 5.month.ago) }
  let(:finished_csv2) { create(:finished_csv, user: user, created_at: 4.month.ago) }
  let(:finished_csv3) { create(:finished_csv, user: user, created_at: 3.month.ago) }
  let(:finished_csv4) { create(:finished_csv, user: user, created_at: 2.month.ago) }
  let(:finished_csv5) { create(:finished_csv, user: user, created_at: 1.month.ago) }
  let(:finished_csv6) { create(:finished_csv, user: user, created_at: 1.day.ago) }

  context 'upload records only one' do
    before { csv }

    it 'shouldn\'t destroy records' do
      subject.perform user
      expect(InventoryDataUpload.count).to eq 1
    end
  end

  context 'upload records 6' do
    before do
      finished_csv1
      finished_csv2
      finished_csv3
      finished_csv4
      finished_csv5
      finished_csv6
    end

    it 'should destroy 1 record' do
      expect(InventoryDataUpload.count).to eq 6
      subject.perform user
      expect(InventoryDataUpload.count).to eq 5
      expect(InventoryDataUpload.all).to include(finished_csv6, finished_csv5, finished_csv4, finished_csv3, finished_csv2)
    end
  end
end
