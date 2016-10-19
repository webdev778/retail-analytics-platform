# frozen_string_literal: true
require 'rails_helper'

describe FileReader::Reader do
  context 'prepare_msku' do
    let(:msku) { ' 08_18_2016_102  ' }
    subject { FileReader::Reader.prepare_msku(msku) }

    it 'should return msku without spaces' do
      expect(subject).to eq '08_18_2016_102'
    end
  end

  context 'prepare_price' do
    let(:price) { '  $2.50  ' }
    subject { FileReader::Reader.prepare_price(price) }

    it 'should return price without spaces' do
      expect(subject).to eq '2.50'
    end
  end

  context 'prepare_date_purchase from csv and xls' do
    let(:date) { ' 6/30/2016 ' }
    subject { FileReader::Reader.prepare_date_purchased(date) }

    it 'should return date' do
      expect(subject).to eq Date.new(2016, 6, 30)
    end
  end

  context 'prepare_date_purchase from txt' do
    let(:date) { '6/30/2016 \n' }
    subject { FileReader::Reader.prepare_date_purchased(date) }

    it 'should return date' do
      expect(subject).to eq Date.new(2016, 6, 30)
    end
  end

  context 'reader' do
    before do
      Timecop.freeze(Time.local(1990))
    end

    after do
      Timecop.return
    end

    context 'csv' do
      let(:csv) { create(:csv) }

      before { FileReader::Reader.new(csv) }

      it 'should import new records' do
        expect(Inventory.count).to eq 4
        csv.reload
        expect(csv.imported_new).to eq 4
        expect(csv.already_exist).to eq 0
        expect(csv.finished_at).to eq(Time.zone.now)
      end
    end

    context 'txt' do
      let(:txt) { create(:txt) }

      before { FileReader::Reader.new(txt) }

      it 'should import new records' do
        expect(Inventory.count).to eq 4
        txt.reload
        expect(txt.imported_new).to eq 4
        expect(txt.already_exist).to eq 0
        expect(txt.finished_at).to eq(Time.zone.now)
      end
    end

    context 'xlsx' do
      let(:xlsx) { create(:xlsx) }

      before { FileReader::Reader.new(xlsx) }

      it 'should import new records' do
        expect(Inventory.count).to eq 4
        xlsx.reload
        expect(xlsx.imported_new).to eq 4
        expect(xlsx.already_exist).to eq 0
        expect(xlsx.finished_at).to eq(Time.zone.now)
      end
    end
  end
end
