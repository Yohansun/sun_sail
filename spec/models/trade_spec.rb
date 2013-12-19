# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Trade do
  let(:current_account) { create(:account) }
  let(:trade) { Fabricate(:trade, account_id: current_account.id) }

  before do
    current_account
    trade
  end

  context "#fetch_account" do
    it "fetch the right account of trade" do
      trade.fetch_account.id.should equal(current_account.id)
      trade.orders.count.should equal(4)
    end
    pending "do nothing when trade has no account_id"
  end

  context "#trade_source" do
  end
end
