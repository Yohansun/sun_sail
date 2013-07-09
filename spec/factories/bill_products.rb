# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bill_product do
    number 1
    real_number 1
    price 100
    total_price 90
  end
end
