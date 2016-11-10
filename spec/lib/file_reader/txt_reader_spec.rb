# frozen_string_literal: true
require 'rails_helper'

describe FileReader::TxtReader do
  describe 'iterate method' do
    context 'first variant headers' do
      let(:file) { create(:txt) }
      subject { FileReader::TxtReader.new(file) }

      it 'should return 4 objects and include known object' do
        t = []
        subject.iterate { |item| t << item }
        expect(t.count).to eq 4
        expect(t.include?(msku: '08_18_2016_102',
                          price: '2.50',
                          date_purchased: Date.new(2016, 6, 30))).to eq true
      end
    end

    context 'second variant headers' do
      let(:file) { create(:txt_second_variant) }
      subject { FileReader::TxtReader.new(file) }

      it 'should return 4 objects and include known object' do
        t = []
        subject.iterate { |item| t << item }
        expect(t.count).to eq 4
        expect(t.include?(msku: '08_18_2016_102',
                          price: '2.50',
                          date_purchased: Date.new(2016, 6, 30))).to eq true
      end
    end

    context 'wrong headers' do
      before do
        Timecop.freeze(Time.local(1990))
      end

      after do
        Timecop.return
      end

      let(:file) { create(:txt_wrong_headers) }
      subject { FileReader::TxtReader.new(file) }

      it 'should return error' do
        t = []
        subject.iterate { |item| t << item }
        expect(t.count).to eq 0
        file.reload

        expect(file.status).to eq 'error'
        expect(file.finished_at).to eq Time.zone.now
        expect(file.description).to eq 'wrong column headers. Should be "MSKU", "Price", "Date Purchased"'
      end
    end
  end
end
