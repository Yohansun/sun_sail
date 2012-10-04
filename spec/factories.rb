FactoryGirl.define do
  factory :user do
    name "foofoo"
    username "foofoo"  
    password "foobar"  
    password_confirmation { |u| u.password }  
    email "foo@example.com"
  end
end