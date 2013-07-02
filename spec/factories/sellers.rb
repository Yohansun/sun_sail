# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seller do
    name Faker::Name.last_name
    fullname Faker::Name.name
  end
end
