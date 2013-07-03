# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_in_bill do
    tid Faker::Lorem.characters(20)
    stock_type "IIR"
    bill_products { [FactoryGirl.build(:bill_product)] }
  end
end
