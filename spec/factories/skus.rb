# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sku do
    product { |obj| FactoryGirl.create(:product,:account_id => obj.account_id)}
  end
end
