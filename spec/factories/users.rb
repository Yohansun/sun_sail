# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    # name "foofoo"
    sequence(:name) { |n| "foo-name-#{n}" }
    sequence(:username) { |n| "test_name#{n}" }
    password "foobar"
    password_confirmation { |u| u.password }
    sequence(:email) { |n| "sequence_#{n}@networking.io" }
    sequence(:phone) { |n| "#{n}1234567890".slice(0..10) }
  end
end