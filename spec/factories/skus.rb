# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sku do
    after(:create) { FactoryGirl.create(:product)}
  end
end
