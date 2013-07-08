# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_out_bill do
    tid Faker::Lorem.characters(20)
    stock_type "ORS"
    bill_products {|obj| [FactoryGirl.build(:bill_product,:sku_id => FactoryGirl.create(:sku,:account_id => obj.account_id).id)] }
  end
end
