# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seller do
    sequence(:name) { |n| "foo-name-#{n}" }
    sequence(:fullname) { |n| "foo-fullname-#{n}" }
  end
end
