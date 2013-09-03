# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :custom_trade do
    tid "TEST00000000000"
    receiver_name "测试人名"
    receiver_mobile "13999999999"
    receiver_state "北京"
    receiver_city "北京市"
    receiver_district "朝阳区"
    receiver_address "测试地址"
    created Time.now
    pay_time Time.now
    status "WAIT_SELLER_SEND_GOODS"
  end
end
