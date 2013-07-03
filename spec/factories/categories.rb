# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| Faker::Lorem.characters(20) + "#{n}" }
    use_days 10
  end
end
