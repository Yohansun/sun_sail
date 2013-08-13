require 'spec_helper'

describe "Homes" do
  describe "GET /homes" do
    login_admin
    it "works! " do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get "/app"
      response.status.should be(200)
    end
  end
end
