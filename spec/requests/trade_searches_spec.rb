require 'spec_helper'


describe "TradeSearches" do
  login_admin

  let(:trade_search){create(:trade_search,{account_id:current_account.id})}
  
  describe "GET /trade_searches" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get trade_searches_path
      response.status.should be(200)
    end
  end


  describe "GET #show" do
    it "should success and response json" do
      get trade_search_path(trade_search,format:"json")
      response.code.should eq("200")
      JSON.parse(response.body)["_id"].should eq(trade_search.id.to_s)
    end
  end



  describe "UPDATE trade_searche" do
    it "should success" do

      get edit_trade_search_path(trade_search)
      response.code.should eq("200")

      trade_search.name = "test trade search"
      put trade_search_path(trade_search, trade_search, format:"json")
      response.code.should eq("406") # :no_content
      trade_search.reload.name.should eq(trade_search.name)
    end
  end

  describe "CREATE trade_search" do
    it "should success" do
      get new_trade_search_path
      response.code.should eq("200")

      exists = TradeSearch.count
      post trade_searches_path({trade_search:{name:"test trade_search2"},format:"json"})
      response.code.should eq("201") # status :created
      TradeSearch.count.should eq(exists+1)

    end
  end

  describe "DESTROY trade_search" do
    it "should success destroy trade_search" do
      delete trade_search_path trade_search
      TradeSearch.where(id:trade_search.id).count.should eq(0)
    end
  end
end
