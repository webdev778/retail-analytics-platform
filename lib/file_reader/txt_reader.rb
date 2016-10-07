module FileReader
  class TxtReader
    def initialize(file)
      @file = CSV.read(file.file_for_import.path, headers: true, header_converters: :symbol)
      @upload_record = file
    end

    def iterate
      # [:msku_price_date_purchased]
      # ["MSKU\tPrice\tDate Purchased"]
      if @file.headers == [:msku_price_date_purchased]
        @file.each do |line|
          # split_string = []
          split_string = line.to_s.split("\t").each_with_object([]) { |row, array| array << row }
          # line.to_s.split("\t").each { |row| split_string << row }
          next unless split_string.count == 3
          msku = Reader.prepare_msku(split_string[0])
          price = Reader.prepare_price(split_string[1])
          date_purchased = Reader.prepare_date_purchased(split_string[2])
          result = { msku: msku,
                     price: price,
                     date_purchased: date_purchased }
          yield result
        end
        Rails.logger.info 'TXT import finished!'
      else
        Rails.logger.info 'TXT import error!'
        @upload_record.update_attributes(finished_at: Time.zone.now,
                                         status: 'error',
                                         description: 'wrong column headers. Should be "MSKU", "Price", "Date Purchased"',
                                         skip_callbacks: true)
      end
    end
  end
end
