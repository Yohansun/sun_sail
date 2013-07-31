require 'spec_helper'

describe "JingdongProducts" do
  describe "GET /jingdong_products" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get jingdong_products_path
      response.status.should be(200)
    end
  end
end
