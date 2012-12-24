FactoryGirl.define do
  factory :user do
    # name "foofoo"
    sequence(:name) { |n| "foo-name-#{n}" }
    username Faker::Name.name
    password "foobar"  
    password_confirmation { |u| u.password }  
    email Faker::Internet.email
  end

  factory :bbs_category do
    name { "Category #{BbsCategory.count + 1}" }
  end

  factory :bbs_topic do
    bbs_category
    user
    title "What's up?"
    body 'bbs topic content'
  end

end