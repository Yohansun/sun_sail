# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :yihaodian_product do
    product_code "MyString"
    product_cname "MyString"
    product_id 1
    ean13 "MyString"
    category_id 1
    can_sale 1
    outer_id "MyString"
    can_show 1
    verify_flg 1
    is_dup_audit 1
    prod_img "MyString"
    prod_detail_url "MyString"
    brand_id 1
    merchant_category_id "MyString"
  end
end
