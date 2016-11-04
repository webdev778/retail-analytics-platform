# frozen_string_literal: true
require 'rails_helper'

describe DataProcessing::DataProcessor do
  let(:user) { create(:user) }

  let(:account) do
    build(:account,
          user: user).save(validate: false)
  end
  let(:marketplace) { create(:marketplace, account: Account.first) }

  let(:report) { create(:report, marketplace: marketplace) }

  let(:received_inventory) do
    create(:received_inventory,
           marketplace: marketplace,
           quantity: 1,
           remain_units: 1,
           product_name: 'first',
           received_date: 4.days.ago,
           sku: '123')
  end
  let(:received_inventory_2) do
    create(:received_inventory,
           marketplace: marketplace,
           quantity: 4,
           remain_units: 4,
           product_name: 'second',
           received_date: 3.days.ago,
           sku: '123')
  end

  before do
    Timecop.freeze(Time.local(1990))
  end

  after do
    Timecop.return
  end

  context 'received_inventories quantity more that in transactions' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 2,
             sku: '123')
    end

    before do
      account
      transaction
      # 2
      received_inventory
      # 1
      received_inventory_2
      # 4
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      report.reload

      expect(received_inventory.sold_units).to eq 1
      expect(received_inventory.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(received_inventory_2.sold_units).to eq 1
      expect(received_inventory_2.remain_units).to eq 3
      expect(received_inventory_2.sold_date).to eq nil
      expect(report.processed).to eq Time.zone.now
    end
  end

  context 'received_inventories less that in transactions' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 6,
             sku: '123')
    end

    before do
      account
      transaction
      # 6
      received_inventory
      # 1
      received_inventory_2
      # 4
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 1
      expect(received_inventory.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(received_inventory_2.sold_units).to eq 4
      expect(received_inventory_2.remain_units).to eq 0
      expect(received_inventory_2.sold_date).to eq transaction.date_time
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 1
    end
  end

  context 'received_inventories eq transactions sold_units_quantity' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 5,
             sku: '123')
    end

    before do
      account
      transaction
      # 5
      received_inventory
      # 1
      received_inventory_2
      # 4
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 1
      expect(received_inventory.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(received_inventory_2.sold_units).to eq 4
      expect(received_inventory_2.remain_units).to eq 0
      expect(received_inventory_2.sold_date).to eq transaction.date_time
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 0
    end
  end

  context 'transaction 5 received inventory 4' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 5,
             sku: '123')
    end
    let(:received_inventory_3) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 4,
             sold_units: 1,
             remain_units: 3,
             product_name: 'third',
             received_date: 2.days.ago,
             sku: '123')
    end

    before do
      account
      transaction
      # 5
      received_inventory
      # quantity: 1,
      received_inventory_3
      # 4
      # 3
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_3.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 1
      expect(received_inventory.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(received_inventory_3.sold_units).to eq 4
      expect(received_inventory_3.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 1
    end
  end

  context 'transaction 5 received inventory list long' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 5,
             sku: '123')
    end
    let(:received_inventory_3) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 4,
             sold_units: 1,
             remain_units: 3,
             product_name: 'third',
             received_date: 2.days.ago,
             sku: '123')
    end

    before do
      account
      transaction
      # 5
      received_inventory
      # quantity: 1,
      received_inventory_2
      # 4
      received_inventory_3
      # 3
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      received_inventory_3.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 1
      expect(received_inventory.remain_units).to eq 0
      expect(received_inventory.sold_date).to eq transaction.date_time
      expect(received_inventory_2.sold_units).to eq 4
      expect(received_inventory_2.remain_units).to eq 0
      expect(received_inventory_2.sold_date).to eq transaction.date_time
      expect(received_inventory_3.sold_units).to eq 1
      expect(received_inventory_3.remain_units).to eq 3
      expect(received_inventory_3.sold_date).to eq nil
      expect(received_inventory_3.remain_units).to eq 3
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 0
    end
  end

  context 'transaction 5 received inventory list long and first enough' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 1.day.ago,
             transaction_type: 'Order',
             quantity: 5,
             sku: '123')
    end

    let(:received_inventory) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 10,
             remain_units: 8,
             sold_units: 2,
             product_name: 'first',
             received_date: 4.days.ago,
             sku: '123')
    end

    let(:received_inventory_3) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 4,
             sold_units: 1,
             remain_units: 3,
             product_name: 'third',
             received_date: 2.days.ago,
             sku: '123')
    end

    before do
      account
      transaction
      # 5
      received_inventory
      # quantity: 8,
      received_inventory_2
      # 4
      received_inventory_3
      # 3
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      received_inventory_3.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 7
      expect(received_inventory.remain_units).to eq 3
      expect(received_inventory.sold_date).to eq nil
      expect(received_inventory_2.remain_units).to eq 4
      expect(received_inventory_2.sold_units).to eq 0
      expect(received_inventory_2.sold_date).to eq nil
      expect(received_inventory_3.sold_units).to eq 1
      expect(received_inventory_3.remain_units).to eq 3
      expect(received_inventory_3.sold_date).to eq nil
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 0
    end
  end

  context 'transaction 5 only last received inventory was received before transaction date' do
    let(:transaction) do
      create(:transaction,
             marketplace: marketplace,
             report: report,
             date_time: 5.day.ago,
             transaction_type: 'Order',
             quantity: 5,
             sku: '123')
    end

    let(:received_inventory) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 10,
             remain_units: 8,
             sold_units: 2,
             product_name: 'first',
             received_date: 4.days.ago,
             sku: '123')
    end

    let(:received_inventory_3) do
      create(:received_inventory,
             marketplace: marketplace,
             quantity: 4,
             sold_units: 1,
             remain_units: 3,
             product_name: 'third',
             received_date: 5.days.ago,
             sku: '123')
    end

    before do
      account
      transaction
      # 5
      received_inventory
      # quantity: 8,
      received_inventory_2
      # 4
      received_inventory_3
      # 3
    end

    subject { DataProcessing::DataProcessor.transaction_processing(report) }

    it 'should process report' do
      subject
      received_inventory.reload
      received_inventory_2.reload
      received_inventory_3.reload
      report.reload
      transaction.reload

      expect(received_inventory.sold_units).to eq 2
      expect(received_inventory.remain_units).to eq 8
      expect(received_inventory.sold_date).to eq nil
      expect(received_inventory_2.remain_units).to eq 4
      expect(received_inventory_2.sold_units).to eq 0
      expect(received_inventory_2.sold_date).to eq nil
      expect(received_inventory_3.sold_units).to eq 4
      expect(received_inventory_3.remain_units).to eq 0
      expect(received_inventory_3.sold_date).to eq received_inventory_3.received_date
      expect(report.processed).to eq Time.zone.now
      expect(transaction.unprocessed_quantity).to eq 2
    end
  end
end
