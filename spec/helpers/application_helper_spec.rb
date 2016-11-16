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

  describe 'value or dash' do
    it 'should return dash' do
      expect(value_or_dash(nil)).to eq '-'
    end

    it 'should return value' do
      expect(value_or_dash(1)).to eq 1
    end
  end

  describe 'format value' do
    it 'should return not available' do
      expect(format_value(nil)).to eq 'N/A'
    end

    it 'should return number' do
      expect(format_value(12)).to eq '12'
    end

    it 'should return number with percent' do
      expect(format_value(12, percentages: true)).to eq '12 %'
    end

    it 'should return decimal number' do
      expect(format_value(12.450, decimal: true)).to eq '12,45'
    end

    it 'should return decimal number with percent' do
      expect(format_value(12.450, percentages: true, decimal: true)).to eq '12,45 %'
    end
  end

  describe 'format_currency' do
    it 'should return not available' do
      expect(format_currency(nil)).to eq 'N/A'
    end

    it 'should return value' do
      expect(format_currency('12.45')).to eq '$ 12.45'
    end
  end
end
