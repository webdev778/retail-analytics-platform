# frozen_string_literal: true
FactoryGirl.define do
  factory :account do
    user
    seller_id Faker::Number.number(10)
    mws_auth_token Faker::Number.number(10)

    association :marketplace
  end
end
