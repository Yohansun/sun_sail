require "spec_helper"

describe YihaodianProductsController do
  describe "routing" do

    it "routes to #index" do
      get("/yihaodian_products").should route_to("yihaodian_products#index")
    end

    it "routes to #new" do
      get("/yihaodian_products/new").should route_to("yihaodian_products#new")
    end

    it "routes to #show" do
      get("/yihaodian_products/1").should route_to("yihaodian_products#show", :id => "1")
    end

    it "routes to #edit" do
      get("/yihaodian_products/1/edit").should route_to("yihaodian_products#edit", :id => "1")
    end

    it "routes to #create" do
      post("/yihaodian_products").should route_to("yihaodian_products#create")
    end

    it "routes to #update" do
      put("/yihaodian_products/1").should route_to("yihaodian_products#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/yihaodian_products/1").should route_to("yihaodian_products#destroy", :id => "1")
    end

  end
end
