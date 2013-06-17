#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reconcile_statement do
    trade_store_source 'tmall'
    trade_store_name '宝尊'
    balance_amount  1234569
    audited false
    audit_time "2012-12-01 00:00:00".to_time(:local)
  end
end
