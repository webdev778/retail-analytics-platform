# frozen_string_literal: true
require 'rails_helper'

describe ApplicationHelper do
  describe 'file extention check' do
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

  describe 'file_status check' do
    it 'should return finished' do
      file = double('file')
      allow(file).to receive(:status).and_return('finished')
      expect(file_status(file)).to eq 'finished'
    end

    it 'should return text' do
      file = double('file')
      allow(file).to receive(:status).and_return('')
      expect(file_status(file)).to eq 'will be proceed in few minutes'
    end
  end

  describe 'format_datetime check' do
    let(:date) { Date.new(2001, 2, 3) }

    it 'should return formatted date' do
      expect(format_datetime(date)).to eq('03/02/2001')
    end

    it 'should return dash' do
      expect(format_datetime(nil)).to eq('-')
    end
  end
end
