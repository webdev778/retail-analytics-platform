# frozen_string_literal: true
FactoryGirl.define do
  factory :marketplace do
    user
    external_marketplace_id Faker::Number.number(10)
    aws_access_key_id Faker::Number.number(10)
    secret_key Faker::Number.number(10)
  end
end
