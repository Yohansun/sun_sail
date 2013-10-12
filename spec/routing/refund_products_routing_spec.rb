require "spec_helper"

describe RefundProductsController do
  describe "routing" do

    it "routes to #index" do
      get("/refund_products").should route_to("refund_products#index")
    end

    it "routes to #new" do
      get("/refund_products/new").should route_to("refund_products#new")
    end

    it "routes to #show" do
      get("/refund_products/1").should route_to("refund_products#show", :id => "1")
    end

    it "routes to #edit" do
      get("/refund_products/1/edit").should route_to("refund_products#edit", :id => "1")
    end

    it "routes to #create" do
      post("/refund_products").should route_to("refund_products#create")
    end

    it "routes to #update" do
      put("/refund_products/1").should route_to("refund_products#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/refund_products/1").should route_to("refund_products#destroy", :id => "1")
    end

  end
end
