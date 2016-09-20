require 'rails_helper'

describe FileReader::Reader do

  context 'prepare_msku' do
    let(:msku) { ' 08_18_2016_102  '}
    subject { FileReader::Reader.prepare_msku(msku) }

    it 'should return msku without spaces' do
      expect(subject).to eq '08_18_2016_102'
    end
  end

  context 'prepare_price' do
    let(:price) { '  $2.50  '}
    subject { FileReader::Reader.prepare_price(price) }

    it 'should return price without spaces' do
      expect(subject).to eq '2.50'
    end
  end

  context 'prepare_date_purchase from csv and xls' do
    let(:date) { ' 6/30/2016 '}
    subject { FileReader::Reader.prepare_date_purchased(date) }

    it 'should return date' do
      expect(subject).to eq Date.new(2016, 6, 30)
    end
  end

  context 'prepare_date_purchase from txt' do
    let(:date) { '6/30/2016 \n'}
    subject { FileReader::Reader.prepare_date_purchased(date) }

    it 'should return date' do
      expect(subject).to eq Date.new(2016, 6, 30)
    end
  end

  context 'reader' do
    
  end
end
