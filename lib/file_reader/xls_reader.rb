module FileReader
  class XlsReader
    def initialize(file)
      @file = Roo::Spreadsheet.open(file.file_for_import.path)
    end

    def iterate
      if @file.row(1) == ['MSKU', 'Price', 'Date Purchased']
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
      end
    end
  end
end
