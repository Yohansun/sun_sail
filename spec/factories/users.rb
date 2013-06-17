# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    # name "foofoo"
    sequence(:name) { |n| "foo-name-#{n}" }
    username Faker::Name.name
    password "foobar"
    password_confirmation { |u| u.password }
    email Faker::Internet.email
    phone "13153183333"
  end
end
