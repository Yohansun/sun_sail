require "spec_helper"

describe StocksController do
  describe "routing" do

    it "routes to #index" do
      get("/stocks").should route_to("stocks#index")
    end

    pending "routes to #old" do
      get("/stocks/old").should route_to("stocks#old")
    end

    it "routes to #safe_stock" do
      get("/stocks/safe_stock").should route_to("stocks#safe_stock")
    end

    it "routes to #change_product_type" do
      get("/stocks/change_product_type").should route_to("stocks#change_product_type")
    end

    it "routes to #edit_depot" do
      get("/stocks/edit_depot").should route_to("stocks#edit_depot")
    end

    it "routes to #update_depot" do
      put("/stocks/1/update_depot").should route_to("stocks#update_depot",:id => "1")
    end

    it "routes to #edit_safe_stock" do
      post("/stocks/edit_safe_stock").should route_to("stocks#edit_safe_stock")
    end

    it "routes to #batch_update_safety_stock" do
      post("/stocks/batch_update_safety_stock").should route_to("stocks#batch_update_safety_stock")
    end

    it "routes to #batch_update_actual_stock" do
      post("/stocks/batch_update_actual_stock").should route_to("stocks#batch_update_actual_stock")
    end
  end
end