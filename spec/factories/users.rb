# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    # name "foofoo"
    sequence(:name) { |n| "foo-name-#{n}" }
    sequence(:username) { |n| "#{Faker::Name.name.delete(" ").slice(1..5)}" }
    password "foobar"
    password_confirmation { |u| u.password }
    sequence(:email) { |n| "sequence_#{n}@networking.io" }
  end
end
