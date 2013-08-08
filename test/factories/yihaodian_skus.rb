# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :yihaodian_sku do
    product_code "MyString"
    product_cname "MyString"
    product_id 1
    ean13 "MyString"
    category_id 1
    can_sale 1
    outer_id "MyString"
    can_show 1
  end
end
