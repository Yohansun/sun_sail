#encoding: utf-8
require 'spec_helper'
describe CustomersPuller do

  let(:dulux)   {FactoryGirl.create(:account,:name => "dulux",:key => "dulux")}
  let(:vanward) {FactoryGirl.create(:account,:name => "vanward",:key => "vanward")}
  before(:each) do
    dulux && vanward
    (39..60).each do |tid|
      name = tid < 41 ? "foo" : tid < 51 ? "bar" : tid < 61 ? "zes" : ""
      FactoryGirl.create(:taobao_trade,account_id: dulux.id ,buyer_nick: name, tid: tid,:status => "WAIT_BUYER_PAY")
    end
    CustomersPuller.initialize!
  end

  def news_trades
    (9..21).each do |tid|
      name = tid < 11 ? "foo" : tid < 21 ? "bar" : tid < 31 ? "zes" : " "
      FactoryGirl.create(:taobao_trade,account_id: vanward.id ,buyer_nick: name, tid: tid,:status => "TRADE_NO_CREATE_PAY")
    end
  end


  context "Test Customer Puller" do
    it "initialize!" do
      customers_count = Customer.where(:account_id => dulux.id).count
      customers_count.should == 3
      news_trades
      expect {CustomersPuller.initialize!}.to raise_error("Already initialized!")
      Customer.where(:account_id => vanward.id).count.should == 0
      CustomersPuller.initialize!(vanward.id)
      Customer.where(:account_id => vanward.id).count.should == 3
    end

    it "update" do
      taobao_trades = TaobaoTrade.where(:account_id => dulux.id,:buyer_nick => "foo")
      taobao_trades.limit(2).each {|taobao_trade| taobao_trade.update_attributes!(:status => "WAIT_SELLER_SEND_GOODS",:news => 1)}
      CustomersPuller.update
      customer = Customer.search(:transaction_histories_status_in => ["WAIT_SELLER_SEND_GOODS"])
      customer.count.should == 1
      transaction_histories = customer.first.transaction_histories.where(:status => "WAIT_SELLER_SEND_GOODS")
      transaction_histories.count.should == 2
    end

    it "sync (本地订单为空结束同步)" do
      TaobaoTrade.delete_all && Customer.delete_all
      CustomersPuller.sync
      Customer.count.should == 0
    end

    it "sync (指定account_id)" do
      news_trades
      FactoryGirl.create(:taobao_trade,account_id: vanward.id ,buyer_nick: "zes", tid: "30",:status => "TRADE_NO_CREATE_PAY")
      CustomersPuller.sync(vanward.id)
      Customer.count.should == 6
      customer = Customer.find_by(:account_id => vanward.id,:name => "zes")
      transaction_histories = customer.transaction_histories
      transaction_histories.count.should == 2
    end
  end
end