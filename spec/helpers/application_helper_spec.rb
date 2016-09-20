require 'rails_helper'

describe ApplicationHelper do
  let(:csv) { create(:csv) }
  let(:txt) { create(:txt) }
  let(:xlsx) { create(:xlsx) }

  context 'work with csv file' do
    subject { file_extention(csv.file_for_import_file_name) }

    it 'should return .csv' do
      expect(subject).to eq '.csv'
    end
  end

  context 'work with txt file' do
    subject { file_extention(txt.file_for_import_file_name) }

    it 'should return .txt' do
      expect(subject).to eq '.txt'
    end
  end

  context 'work with xlsx file' do
    subject { file_extention(xlsx.file_for_import_file_name) }

    it 'should return .xlsx' do
      expect(subject).to eq '.xlsx'
    end
  end
end
