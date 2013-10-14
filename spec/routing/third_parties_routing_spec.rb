require "spec_helper"

describe ThirdPartiesController do
  describe "routing" do

    it "routes to #index" do
      get("/third_parties").should route_to("third_parties#index")
    end

    it "routes to #new" do
      get("/third_parties/new").should route_to("third_parties#new")
    end

    it "routes to #show" do
      get("/third_parties/1").should route_to("third_parties#show", :id => "1")
    end

    it "routes to #edit" do
      get("/third_parties/1/edit").should route_to("third_parties#edit", :id => "1")
    end

    it "routes to #create" do
      post("/third_parties").should route_to("third_parties#create")
    end

    it "routes to #update" do
      put("/third_parties/1").should route_to("third_parties#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/third_parties/1").should route_to("third_parties#destroy", :id => "1")
    end

  end
end
