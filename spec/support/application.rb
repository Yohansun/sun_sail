module MagicOrders
  module TestHelpers

    def sign_in(current_user)
      controller.stub(:current_user).and_return(current_user)
      request.env['HTTP_REFERER'] = root_url
    end

  end
end

RSpec.configure do |config|
  config.include MagicOrders::TestHelpers
end
