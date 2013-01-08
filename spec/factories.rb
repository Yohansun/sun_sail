# encoding: utf-8
FactoryGirl.define do
  factory :user do
    # name "foofoo"
    sequence(:name) { |n| "foo-name-#{n}" }
    username Faker::Name.name
    password "foobar"  
    password_confirmation { |u| u.password }  
    email Faker::Internet.email
  end

  factory :bbs_category do
    name { "Category #{BbsCategory.count + 1}" }
  end

  factory :bbs_topic do
    bbs_category
    user
    title "What's up?"
    body 'bbs topic content'
  end

  factory :reconcile_statement do
    trade_store_source 'tmall'
    trade_store_name '宝尊'
    balance_amount  1234569
    audited false
    audit_time "2012-12-01 00:00:00".to_time(:local)
  end

  factory :reconcile_statement_detail do
    reconcile_statement
  end

  factory :alipay_trade_history do
  end

  factory :alipay_trade_order do
  end

  factory :trade do
  end

  factory :trade_source do
    name "淘宝商城"
  end 
  
  factory :trade do
  end

  factory :taobao_order do
  end

  factory :jingdong_order do
  end

  factory :taobao_sub_purchase_order do
  end

  factory :taobao_trade do
  end

  factory :jingdong_trade do
  end

  factory :taobao_purchase_order do
  end

end