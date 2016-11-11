# frozen_string_literal: true
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :inventory_data_upload do
    user

    factory :csv do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload.csv'), 'text/plain') }

      factory :finished_csv do
        finished_at { Time.zone.now }
      end
    end

    factory :csv_second_variant do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_second_variant_headers.csv'), 'text/plain') }
    end

    factory :csv_wrong_headers do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_wrong_headers.csv'), 'text/plain') }
    end

    factory :txt do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload.txt'), 'text/plain') }
    end

    factory :txt_second_variant do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_second_variant_headers.txt'), 'text/plain') }
    end

    factory :txt_wrong_headers do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_wrong_headers.txt'), 'text/plain') }
    end
    factory :xlsx do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    end

    factory :xlsx_second_variant do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_second_variant_headers.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    end

    factory :xlsx_wrong_headers do
      file_for_import { fixture_file_upload(Rails.root.join('spec/fixtures/files/Inventory_Upload_wrong_headers.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    end
  end
end
