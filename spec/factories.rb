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
  end

  factory :reconcile_statement_detail do
    reconcile_statement
  end

end