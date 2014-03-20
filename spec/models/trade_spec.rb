# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Trade do
  let(:current_account) { create(:account) }
  let(:taobao_trade) { Fabricate(:taobao_trade, account_id: current_account.id) }

  before do
    current_account
    taobao_trade
  end

##### 状态更新测试 #####
  context "trade update" do

    it "should assign has_cs_memo" do
      taobao_trade.update_attributes(cs_memo: "test_memo")
      taobao_trade.has_cs_memo.should be_true
    end

    it "should assign has_refund_orders" do
      taobao_trade.orders.first.update_attributes(refund_status: "SUCCESS")
      taobao_trade.has_refund_orders.should be_true
    end

    it "should assign has_unusual_state" do
      taobao_trade.unusual_states.create(reason: "买家延迟发货")
      taobao_trade.has_unusual_state.should be_true
    end

    it "should assign has_property_memos" do
      taobao_trade.trade_property_memos.create()
      taobao_trade.has_property_memos.should be_true
    end
  end

##### 订单删除测试 #####
  context "trade destroy" do
    it "should delete all deliver_bills belongs to the trade" do
      taobao_trade.generate_deliver_bill
      trade_id = taobao_trade.id
      taobao_trade.destroy
      DeliverBill.where(trade_id: trade_id).count.should eq(0)
    end
  end

##### 操作人设置测试 #####
  context "#set_operator" do
  end

##### 匹配经销商测试 #####
  context "#matched_seller_with_default" do
  end

##### 发货单生成测试 #####
  context "#generate_deliver_bill" do
  end

##### 物流单生成测试 #####
  context "#generate_stock_out_bill" do
  end

##### 手动分流测试 #####
  context "#dispatch!" do
  end

##### 自动分流测试 #####
  context "#auto_dispatch!" do
  end

##### 分流重置测试 #####
  context "#reset_seller" do
  end

##### 匹配物流商测试 #####
  context "#matched_logistics" do
  end

##### 手动发货测试 #####
  context "#deliver!" do
  end

##### 自动发货测试 #####
  context "#auto_deliver!" do
  end

##### 搜索测试 #####
  context "#filter" do
  end

end
