# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :taobao_product do
    name "测试商品"
    num_iid 1234567
    outer_id "432435-AS"
    price 123.4
    cid 123
    pic_url "/test/pic/001"
  end
end
