module FileReader
  class Reader
    include ApplicationHelper
    class << self
      def prepare_msku(msku)
        msku.to_s.delete(' ').to_s
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
      @current_user = inventory_data_upload.user
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
        inventory_params = data.slice(:msku, :price, :date_purchased)
        inventory = @current_user.inventories.find_by(inventory_params)
        if inventory
          count_of_existing_records += 1
        else
          @current_user.inventories.create(inventory_params)
          count_of_new_records += 1
        end
      end

      @file_record.update_attributes(finished_at: Time.zone.now,
                                     imported_new: count_of_new_records,
                                     already_exist: count_of_existing_records,
                                     skip_callbacks: true)
    end
  end
end
