module FileReader
  class Reader
    include ApplicationHelper
    class << self
      def prepare_msku(msku)
        msku.delete(' ').to_s
      end

      def prepare_price(price)
        price.sub('$', '').delete(' ').to_s
      end

      def prepare_date_purchased(date)
        date = date.delete("\n").to_s
        Date.strptime(date.delete(' '), '%m/%d/%Y')
      end
    end

    def initialize(inventory_data_upload)
      @file_record = inventory_data_upload
      check_type
    end

    private

    def check_type
      count_of_new_records = 0
      count_of_existing_records = 0
      if @file_record.file_for_import.content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        reader = FileReader::XlsReader.new @file_record
      elsif file_extention(@file_record.file_for_import_file_name) == '.csv'
        reader = FileReader::CsvReader.new @file_record
      elsif file_extention(@file_record.file_for_import_file_name) == '.txt'
        reader = FileReader::TxtReader.new @file_record
      else
        Rails.logger.info 'Error wrong extention'
      end

      reader.iterate do |data|
        begin
          inventory = Inventory.find_or_initialize_by(msku: data[:msku],
                                                      price: data[:price],
                                                      date_purchased: data[:date_purchased])
          if inventory.new_record?
            inventory.save!
            count_of_new_records += 1
          else
            count_of_existing_records += 1
          end
        rescue
          next
        end
      end
      @file_record.update_attributes(finished_at: Time.zone.now,
                                     imported_new: count_of_new_records,
                                     already_exist: count_of_existing_records,
                                     skip_callbacks: true)
    end
  end
end
