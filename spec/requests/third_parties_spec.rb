require 'spec_helper'

describe "ThirdParties" do
  describe "GET /third_parties" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get third_parties_path
      response.status.should be(200)
    end
  end
end
