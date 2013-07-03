# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_bill do
    tid Faker::Lorem.characters(20)
  end
end
