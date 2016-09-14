class InventoryDataUpload < ApplicationRecord
  has_attached_file :file_for_import

  validates_attachment_content_type :file_for_import,
                                    content_type: ['text/plain', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
                                    message: 'Allowed only .txt, .csv, .xls, .xlsx files extentions'
  validates_attachment_presence :file_for_import

  # ['text/csv', text/comma-separated-values', 'text/csv', application/csv', 'application/excel', 'application/vnd.ms-excel', 'application/vnd.msexcel', 'text/anytext', 'text/plain', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  belongs_to :user

  after_save :check_headers

  private

  def check_headers
    if file_for_import.content_type == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      file = Roo::Spreadsheet.open(file_for_import.path)
      if file.row(1) == ['MSKU', 'Price', 'Date Purchased']
        file.each_with_index do |line, index|
          unless index == 0
            msku = prepare_msku(line[0])
            price = line[1]
            date_purchased = line[2]
            Inventory.find_or_create_by(msku: msku, price: price, date_purchased: date_purchased)
          end
        end
      else
        Rails.logger.info 'Error while XLS import'
      #   TODO: return error message
      end
    else
      file = CSV.read(file_for_import.path, headers: true)
      if file.headers == ['MSKU', 'Price', 'Date Purchased']
        file.each do |line|
          msku = prepare_msku(line['MSKU'])
          price = prepare_price(line['Price'])
          date_purchased = prepare_date_purchased(line['Date Purchased'])
          Inventory.find_or_create_by(msku: msku, price: price, date_purchased: date_purchased)
        end
      elsif file.headers == ["MSKU\tPrice\tDate Purchased"]
        file = CSV.read(file_for_import.path, headers: true, header_converters: :symbol)
        file.each do |line|
          split_string = []
          line.to_s.split("\t").each { |row| split_string << row  }
          if split_string.count == 3
            msku = prepare_msku(split_string[0])
            price = prepare_price(split_string[1])
            date_purchased = prepare_date_purchased(split_string[2])
            Inventory.find_or_create_by(msku: msku, price: price, date_purchased: date_purchased)
          else
            Rails.logger.info 'Error while txt import rows count mistake'
          #   TODO : string with mistake
          end
        end
      else
        Rails.logger.info 'Error while CSV import'
      #   TODO: return file not valid
      end
    end
  end

  def prepare_msku(msku)
    msku.delete(' ')
  end

  def prepare_price(price)
    price.sub('$', '').delete(' ')
  end

  def prepare_date_purchased(date)
    date = date.delete("\n")
    Date.strptime(date.delete(' '), '%m/%d/%Y')
  end
end
