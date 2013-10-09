# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_csv_file do
    path Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/test.csv')))
  end
end
