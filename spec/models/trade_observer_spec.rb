# -*- encoding : utf-8 -*-
require 'spec_helper'

describe TradeObserver do

  let(:current_account) { create(:account) }
  let(:role) { create(:role,:account_id => current_account.id) }
  let(:current_user) { create(:user,:username => "test",:password => "123456", accounts: [current_account],:roles => [role]) }
  let(:trade) { Fabricate(:trade, account_id: current_account.id) }
  let(:merge_trade_1) { Fabricate(:trade, _id: "51e7c5d4046d500263000005", _type: "TaobaoTrade", account_id: current_account.id) }
  let(:merge_trade_2) { Fabricate(:trade, _id: "51e7c648046d50026300000a", _type: "TaobaoTrade", account_id: current_account.id) }

  before(:each) do
    current_account.settings[:wizard_step] = :finish
    current_user.superadmin!
  end

  describe "#around_update" do
    before do
      merge_trade_1.delete
      merge_trade_2.delete
    end
    it "update sub merged_trade while update merged_trade" do
      trade.update_attributes(seller_id: 1024,
                              status: "TRADE_FINISHED",
                              logistic_waybill: "TEST1024",
                              logistic_code: "YTO")

      Trade.deleted.where(_id: merge_trade_1.id).first.seller_id.should eq(1024)
      Trade.deleted.where(_id: merge_trade_2.id).first.status.should eq("TRADE_FINISHED")
      Trade.deleted.where(_id: merge_trade_1.id).first.logistic_waybill.should eq("TEST1024")
      Trade.deleted.where(_id: merge_trade_2.id).first.logistic_code.should eq("YTO")
    end

    it "stay the same if specific fields of main trade are changed" do
      trade.update_attributes(cs_memo: "HOHO",
                              payment: 1024)
      Trade.deleted.where(_id: merge_trade_1.id).first.cs_memo.should_not eq("HOHO")
      Trade.deleted.where(_id: merge_trade_2.id).first.payment.should_not eq(1024)
    end
  end
end