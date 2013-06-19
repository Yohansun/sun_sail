require 'spec_helper'

describe "Skus" do
  login_admin
  
  describe "GET /skus" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      product = FactoryGirl.create(:product)
      get product_skus_path(product)
      response.status.should be(200)
    end
  end
end
