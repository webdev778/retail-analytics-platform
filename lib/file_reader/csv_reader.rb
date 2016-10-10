module FileReader
  class CsvReader
    def initialize(file)
      @file = CSV.read(file.file_for_import.path, headers: true)
      @upload_record = file
    end

    def iterate
      if @file.headers == (['MSKU', 'Price', 'Date Purchased'] || ['SellerSKU', 'Price Per Unit', 'Date Purchased'])
        @file.each do |line|
          msku = Reader.prepare_msku(line['MSKU'] || line['SellerSKU'])
          price = Reader.prepare_price(line['Price'] || line['Price Per Unit'])
          date_purchased = Reader.prepare_date_purchased(line['Date Purchased'])
          result = { msku: msku,
                     price: price,
                     date_purchased: date_purchased }
          yield result
        end
        Rails.logger.info 'CSV import finished!'
      else
        Rails.logger.info 'CSV import error!'
        @upload_record.update_attributes(finished_at: Time.zone.now,
                                         status: 'error',
                                         description: 'wrong column headers. Should be "MSKU", "Price", "Date Purchased"',
                                         skip_callbacks: true)
      end
    end
  end
end
