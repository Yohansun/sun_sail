require "spec_helper"

describe SkusController do
  describe "routing" do

    it "routes to #index" do
      get("/products/1/skus").should route_to("skus#index",:product_id => "1")
    end

    it "routes to #new" do
      get("/products/1/skus/new").should route_to("skus#new",:product_id => "1")
    end

    it "routes to #show" do
      get("/products/1/skus/1").should route_to("skus#show",:product_id => "1", :id => "1")
    end

    it "routes to #edit" do
      get("/products/1/skus/1/edit").should route_to("skus#edit",:product_id => "1", :id => "1")
    end

    it "routes to #create" do
      post("/products/1/skus").should route_to("skus#create",:product_id => "1")
    end

    it "routes to #update" do
      put("/products/1/skus/1").should route_to("skus#update",:product_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      delete("/products/1/skus/1").should route_to("skus#destroy",:product_id => "1", :id => "1")
    end

  end
end
