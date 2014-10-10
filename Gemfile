source 'http://ruby.taobao.org/'

# invalid byte sequence in US-ASCII (ArgumentError)
if RUBY_VERSION =~ /1.9/ # assuming you're running Ruby ~1.9
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '>= 3.2.11'

gem 'mysql2'

gem 'json'
gem 'crack'
gem 'rabl'
gem 'jbuilder'

gem "meta_search"
gem 'hipchat'
gem 'whenever',"~> 0.8.3", :require => false

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'turbo-sprockets-rails3',"0.3.11"
end

gem 'jquery-rails'
# auditing or versioning
gem "audited-activerecord", "~> 3.0"
gem 'paper_trail', '~> 3.0.0'

gem 'awesome_print',"~> 1.2.0"
group :test, :development do
  # gem "debugger"
  gem "guard"
  gem "guard-bundler"
  gem "guard-rspec"
  gem 'guard-spork'
  gem "annotate", '~> 2.4.1.beta1'
  gem 'guard-annotate'
  gem "rspec-instafail"
  gem "rspec-rails"
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'database_cleaner'
  gem 'factory_girl_rails',:require => false
  gem 'faker'
  gem "shoulda-matchers"
  gem 'webrat'
  gem "capybara"
  # gem 'capybara-webkit'
  gem "cucumber"
  gem 'capistrano', '~> 2.15.4'
  gem "capistrano-ext"
  gem 'quiet_assets'
  gem 'bond'
  gem 'puma'
  gem 'wirble'
  gem 'map_by_method'
  gem 'hirb'
  gem 'rvm-capistrano'
  gem 'tinder'
  gem 'certified'
  gem "thin"
  gem "letter_opener"
  gem "simplecov", :require => false
  gem 'fabrication'
end

gem 'strong_parameters'
gem 'mongoid', '3.1.0'
gem 'draper'
gem 'inherited_resources'
gem 'devise'
gem 'devise-encryptable'
gem 'rails-settings', git: 'git://github.com/pomelolabs/rails-settings.git'
gem 'twitter-bootstrap-rails', '>= 2.1.9'
gem "less-rails"
gem 'therubyracer',"~> 0.12.0"
gem 'simple_form'
gem "kiqstand"
gem 'awesome_nested_set'
gem 'kaminari'
gem 'rolify'
gem 'backbone-on-rails'
gem "act_as_cached", "~> 0.0.3"
gem 'taobao_fu_reload', "~> 1.1.2"
gem 'jingdong_fu'

gem 'hz2py'

gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'slim'
gem 'sinatra', :require => nil

gem 'savon', '2.1.0'
gem 'wash_out', '0.6.1'
gem 'collections'
gem 'spreadsheet'
gem 'ekuseru'
gem 'carrierwave'
gem "mini_magick"

gem 'redis-namespace'
gem 'redis-rails',"~> 3.2.4"

gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'rest-client'
gem 'httparty'
gem 'rchardet19'
gem 'state_machine', "~> 1.2.0"

gem 'mongoid-history'

#test mail
gem "mails_viewer"
gem 'wicked'
gem "paperclip", "~> 2.4"

#Schedule works using sidekiq
gem "clockwork", "~> 0.5.0"

#Handle CSV import
gem 'csv-mapper', '~> 0.5.1'

# API
gem 'grape', "~> 0.5.0"
gem "grape-entity"

# third party data sync
# gem 'third_party_sync',git: "git@git.networking.io:ddl1st/third_party_sync.git",branch: "v0.0.3"

group :production do
  gem "exception_notification", "~> 2.6.1"
  gem 'newrelic_rpm'
end
gem "iconv"