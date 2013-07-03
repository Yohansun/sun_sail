# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_out_bill do
    tid Faker::Lorem.characters(20)
    stock_type "ORS"
    bill_products { [FactoryGirl.build(:bill_product)] }
    after(:create) {|obj| create(:sku,:product => create(:product,:account_id => obj.account_id))}
  end
end
