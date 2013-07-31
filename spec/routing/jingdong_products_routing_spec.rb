require "spec_helper"

describe JingdongProductsController do
  describe "routing" do

    it "routes to #index" do
      get("/jingdong_products").should route_to("jingdong_products#index")
    end

    it "routes to #new" do
      get("/jingdong_products/new").should route_to("jingdong_products#new")
    end

    it "routes to #show" do
      get("/jingdong_products/1").should route_to("jingdong_products#show", :id => "1")
    end

    it "routes to #edit" do
      get("/jingdong_products/1/edit").should route_to("jingdong_products#edit", :id => "1")
    end

    it "routes to #create" do
      post("/jingdong_products").should route_to("jingdong_products#create")
    end

    it "routes to #update" do
      put("/jingdong_products/1").should route_to("jingdong_products#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/jingdong_products/1").should route_to("jingdong_products#destroy", :id => "1")
    end

  end
end
