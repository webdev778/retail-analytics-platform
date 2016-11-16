# frozen_string_literal: true
module FileReader
  class XlsReader
    def initialize(file)
      @file = Roo::Spreadsheet.open(file.file_for_import.path)
      @upload_record = file
    end

    def iterate
      if %w(MSKU SellerSKU).include?(@file.row(1).first) && ['Price', 'Price Per Unit'].include?(@file.row(1).second) && ['Date Purchased'].include?(@file.row(1).third)
        @file.each_with_index do |line, index|
          next if index.zero?
          msku = Reader.prepare_msku(line[0])
          price = line[1]
          date_purchased = line[2]
          result = { msku: msku,
                     price: price,
                     date_purchased: date_purchased }
          yield result
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
