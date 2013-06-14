# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    outer_id 'test'
    name 'test'
    storage_num '12345678a'
  end
end
