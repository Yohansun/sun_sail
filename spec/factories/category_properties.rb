# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category_property do
    name "颜色分类"
    value_type 1
    status 1
  end
end
