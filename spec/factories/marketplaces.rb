FactoryGirl.define do
  factory :marketplace do
    user

    external_marketplace_id 'test'
    aws_access_key_id 'test'
    secret_key 'test'
  end
end
