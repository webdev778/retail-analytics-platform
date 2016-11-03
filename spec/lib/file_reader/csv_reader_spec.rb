# frozen_string_literal: true
require 'rails_helper'

describe FileReader::CsvReader do
  context 'check iterate method' do
    let(:file) { create(:csv) }
    subject(:csv_file) { FileReader::CsvReader.new(file) }
  end
end
