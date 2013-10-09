# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    sequence(:outer_id)  {|n| "T000000#{n}" }
    sequence(:num_iid)  {|n| "123456#{n}" }
    sequence(:storage_num) {|n| "12345678#{n}a" }
    name Faker::Name.last_name
    price 1
    after(:create) {|obj| create(:category)}
  end
end
