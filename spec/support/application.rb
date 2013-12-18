module MagicOrders
  module TestHelpers

    def sign_in(current_user)
      if current_user.nil?
        request.env['warden'].stub(:authenticate!).
          and_throw(:warden, {:scope => :user})
        controller.stub :current_user => nil
      else
        request.env['warden'].stub :authenticate! => current_user
        controller.stub :current_user => current_user
      end
    end


    def set_current_account(account)
      if account.nil?
        controller.stub :current_account => nil
      else
        controller.stub :current_account => account
      end
    end

  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include MagicOrders::TestHelpers
end
