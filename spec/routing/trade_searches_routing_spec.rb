require "spec_helper"

describe TradeSearchesController do
  describe "routing" do

    it "routes to #index" do
      get("/trade_searches").should route_to("trade_searches#index")
    end

    it "routes to #new" do
      get("/trade_searches/new").should route_to("trade_searches#new")
    end

    it "routes to #show" do
      get("/trade_searches/1").should route_to("trade_searches#show", :id => "1")
    end

    it "routes to #edit" do
      get("/trade_searches/1/edit").should route_to("trade_searches#edit", :id => "1")
    end

    it "routes to #create" do
      post("/trade_searches").should route_to("trade_searches#create")
    end

    it "routes to #update" do
      put("/trade_searches/1").should route_to("trade_searches#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/trade_searches/1").should route_to("trade_searches#destroy", :id => "1")
    end

  end
end
