# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bbs_category do
    name { "Category #{BbsCategory.count + 1}" }
  end
end
