module FileReader
  class XlsReader
    def initialize(file)
      @file = Roo::Spreadsheet.open(file.file_for_import.path)
      @upload_record = file
    end

    def iterate
      if @file.row(1) == ['MSKU', 'Price', 'Date Purchased'] || ['SellerSKU', 'Price Per Unit', 'Date Purchased']
        @file.each_with_index do |line, index|
          unless index.zero?
            byebug
            msku = Reader.prepare_msku(line[0])
            price = line[1]
            date_purchased = line[2]
            result = { msku: msku,
                       price: price,
                       date_purchased: date_purchased }
            yield result
          end
        end
        Rails.logger.info 'XLS import finished!'
      else
        Rails.logger.info 'XLS import error!'
        @upload_record.update_attributes(finished_at: Time.zone.now,
                                          status: 'error',
                                          description: 'wrong column headers. Should be "MSKU", "Price", "Date Purchased"',
                                          skip_callbacks: true)
      end
    end
  end
end
