# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'rspec/autorun'
require 'spork'
require 'devise'
require 'factory_girl_rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# module RSpecStubCurrentAccount
#   extend ActiveSupport::Concern
#   included do
#     before do
#       controller.stub!(:current_account).and_return(current_account)
#       controller.stub!(:current_user).and_return(current_user)
#     end
#   end
# end

Spork.prefork do
  require 'draper/test/rspec_integration'
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
    config.include FactoryGirl::Syntax::Methods
    config.include Devise::TestHelpers, type: :controller
    config.extend ControllerMacros    , type: :controller
    config.extend RequestMacros       , type: :request
    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.before(:each) do
      DatabaseCleaner.orm = "mongoid"
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  require 'factory_girl_rails'

  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
# reload factories
# FactoryGirl.definition_file_paths = [File.join(Rails.root, 'spec', 'factories')]
  FactoryGirl.factories.clear
  FactoryGirl.reload
end