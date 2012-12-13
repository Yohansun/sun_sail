FactoryGirl.define do
  factory :user do
    name "foofoo"
    username "foofoo"  
    password "foobar"  
    password_confirmation { |u| u.password }  
    email "foo@example.com"
  end

  factory :bbs_category do
    name "Category 1"
  end

  factory :bbs_topic do
    bbs_category
    user
    title "What's up?"
  end

end