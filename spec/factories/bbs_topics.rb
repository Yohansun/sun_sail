# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bbs_topic do
    bbs_category
    title "What's up?"
    body 'bbs topic content'
  end
end
