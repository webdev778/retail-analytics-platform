module FileReader
  class CsvReader
    def initialize(file)
      @file = CSV.read(file.file_for_import.path, headers: true)
    end

    def iterate
      if @file.headers == ['MSKU', 'Price', 'Date Purchased']
        @file.each do |line|
          msku = Reader.prepare_msku(line['MSKU'])
          price = Reader.prepare_price(line['Price'])
          date_purchased = Reader.prepare_date_purchased(line['Date Purchased'])
          result = { msku: msku,
                     price: price,
                     date_purchased: date_purchased }
          yield result
        end
        Rails.logger.info 'CSV import finished!'
      end
    end
  end
end
