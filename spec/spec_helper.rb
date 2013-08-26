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

def test_bill_status(class_name, state_name)

  state_items = [
                  {
                    :state_name => :checked,
                    :method_name => :do_check,
                    :allow_status => [:created],
                    :unlocked => true,
                    :timestrap_name => "checked_at"
                  },
                  {
                    :state_name => :syncking,
                    :method_name => :do_syncking,
                    :allow_status => [:synck_failed, :checked, :canceld_ok],
                    :unlocked => true,
                    :timestrap_name => "sync_at"
                  },
                  {
                    :state_name => :syncked,
                    :method_name => :do_syncked,
                    :allow_status => [:syncking],
                    :timestrap_name => "sync_succeded_at"
                  },
                  {
                    :state_name => :synck_failed,
                    :method_name => :do_synck_fail,
                    :allow_status => [:syncking],
                    :timestrap_name => "sync_failed_at"
                  },
                  {
                    :state_name => :stocked,
                    :method_name => :do_stock,
                    :allow_status => [:created, :checked, :syncking, :syncked, :synck_failed, :stocked, :canceling, :canceld_ok, :canceld_failed],
                    :timestrap_name => "confirm_stocked_at"
                  },
                  {
                    :state_name => :closed,
                    :method_name => :do_close,
                    :allow_status => [:created, :checked, :synck_failed, :canceld_ok]
                  },
                  {
                    :state_name => :canceling,
                    :method_name => :do_canceling,
                    :allow_status => [:syncked],
                    :unlocked => true,
                    :timestrap_name => "canceled_at"
                  },
                  {
                    :state_name => :canceld_ok,
                    :method_name => :do_cancel_ok,
                    :allow_status => [:canceling],
                    :timestrap_name => "cancel_succeded_at"
                  },
                  {
                    :state_name => :canceld_failed,
                    :method_name => :do_cancel_fail,
                    :allow_status => [:canceling],
                    :timestrap_name => "cancel_failed_at"
                  }
                ]
  s_item = state_items.find{|s| s[:state_name] == state_name}
  if s_item.present?
    sta_name = s_item[:state_name]
    method_name = s_item[:method_name]
    allow_status = s_item[:allow_status]
    timestrap_name = s_item[:timestrap_name]
    only_activated = s_item.has_key?(:unlocked)

    [:none, :activated, :locked].each do |opt|
      [:created, :checked, :syncking, :syncked,
      :synck_failed, :stocked, :closed, :canceling,
      :canceld_ok, :canceld_failed].each do |s_name|
        is_can =  if allow_status.include?(s_name)
                    #是否只允许非锁定stock_bill执行change state
                    if only_activated && ![:activated, :none].include?(opt)
                      false
                    else
                      true
                    end
                  else
                    false
                  end
        if is_can
          change_stock_bill_status_success(class_name, opt, s_name, method_name, timestrap_name)
        else
          change_stock_bill_status_fail(class_name, opt, s_name, method_name, timestrap_name)
        end
      end
    end
  end
end

def change_stock_bill_status_success(class_name, opt_name, sta_name, method_name, timestrap_name)
  #find stock_bill
  stock_bill = FactoryGirl.create("#{opt_name}_#{sta_name}_#{class_name}")
  #验证stock_bill当前state
  stock_bill.state_name.should eql(sta_name)
  #验证stock_bill当前state时间戳
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
  #执行state_machine方法
  stock_bill.send(method_name).should be_true
  #验证stock_bill当前state时间戳(是时间类型)
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(DateTime).should be_true
  end
end

def change_stock_bill_status_fail(class_name, opt_name, sta_name, method_name, timestrap_name)
  #find stock_bill
  stock_bill = FactoryGirl.create("#{opt_name}_#{sta_name}_#{class_name}")
  #验证stock_bill当前state
  stock_bill.state_name.should eql(sta_name)
  #验证stock_bill当前state时间戳
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
  #执行state_machine方法
  stock_bill.send(method_name).should_not be_true
  # #验证stock_bill当前state时间戳(nil)
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
end