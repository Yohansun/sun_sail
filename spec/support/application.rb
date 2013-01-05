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

  end
end

RSpec.configure do |config|
  config.include MagicOrders::TestHelpers
end
