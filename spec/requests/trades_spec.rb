# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Trades" do
  login_admin

  let(:trade) { Fabricate(:trade, account_id: current_account.id) }

  describe "GET /trades" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      xhr :get, trades_path(:json)
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"my_trade")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"undispatched")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"delivered")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"undelivered")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"unusual_all")
      response.status.should be(200)
    end
  end

  describe "export" do
    it "should works" do
      xhr :get, export_trades_path
      response.status.should eq(200)
    end
  end

  describe "notifier" do
    it "should works" do
      xhr :get, notifer_trades_path(trade_type:"taobao")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"taobao_fenxiao")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"jingdong")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"shop")
      response.status.should eq(200)

      xhr :get, notifer_trades_path
      response.status.should eq(200)

    end
  end


  describe "show json" do
    it "should works" do
      xhr :get, trade_path(trade)
      response.status.should eq(200)
      JSON.parse(response.body)["id"].should eq(trade.id.to_s)
    end
  end


  describe "update" do
    it "should works" do
      xhr :put, trade_path(trade),{
        cs_memo:"cs memo"
      }
      response.status.should eq(200)
      Trade.find(trade.id).cs_memo.should eq("cs memo")


      # TODO: add more attribute changes for trade, to covert more controller code
    end
  end


  describe "batch check goods" do
    it "should success" do
      xhr :get, "/trades/batch_check_goods", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "batch export" do
    it "should success" do
      xhr :get, "/trades/batch_export", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "verify add gift" do
    it "should success" do
      xhr :get, "/trades/verify_add_gift", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "batch add gift" do
    it "should success" do
      xhr :get, "/trades/batch_add_gift", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "lock and activate" do
    it "should success" do
      xhr :get, "/trades/lock_trade", id:trade.id.to_s
      response.status.should eq(200)
      trade.reload.is_locked.should eq(true)
      xhr :get, "/trades/activate_trade", id:trade.id.to_s
      response.status.should eq(200)
      trade.reload.is_locked.should eq(false)
    end
  end

  describe "split and merge" do
    it "should success" do
      xhr :get, "trades/split/#{trade.id}"
      response.status.should eq(200)

      #TODO: merge splitted trades
    end
  end


  describe "batch deliver" do
    it "should success" do
      xhr :get, "/trades/batch_deliver",  ids:[trade.id.to_s]
      response.status.should eq(200)
      trade.reload.status.should == "WAIT_BUYER_CONFIRM_GOODS"
    end
  end

  describe "get deliver list" do
    it "should success" do
      xhr :get, "/trades/deliver_list", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end
end
