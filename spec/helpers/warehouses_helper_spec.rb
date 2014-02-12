#encoding: utf-8
require 'spec_helper'
describe WarehousesHelper do
  let(:current_account) { FactoryGirl.create(:account) }
  before(:each) { helper.stub!(:current_account).and_return(current_account) }

  describe "#one_tabs" do
    it "should be equal" do
      helper.one_tabs.should eq({"所有仓库"  => "/warehouses","总库存"  => "/stocks"})
    end
  end

  describe "#warehouse_tabs" do
    let(:warehouse) { seller = mock_model(Seller)}
    before(:each) do
      warehouse.stub!(:id).and_return(1)
    end

    it "should be single warehosue tabs" do
      current_account.sellers.stub!(:count).and_return(1)
      helper.warehouse_tabs(warehouse).should eq({
        "入库单"  => "/warehouses/1/stock_in_bills",
        "出库单"  => "/warehouses/1/stock_out_bills",
        "所有进销" => "/warehouses/1/stock_bills",
        "总库存" => "/warehouses/1/stocks"
        })
    end

    it "should be mutiple warehouses tabs" do
      current_account.sellers.stub!(:count).and_return(2)
      helper.warehouse_tabs(warehouse).should eq({"所有仓库"  => "/warehouses","总库存" => "/stocks"})
    end

    it "should be mutiple warehouse detail page tabs" do
      params = {:controller => "stock_in_bills",:warehouse_id => current_account.sellers.first.id}
      helper.stub!(:params).and_return(params)
      current_account.sellers.stub!(:count).and_return(2)
      helper.warehouse_tabs(warehouse).should eq({
        "入库单"  =>"/warehouses/1/stock_in_bills",
        "出库单"  =>"/warehouses/1/stock_out_bills",
        "所有进销" =>"/warehouses/1/stock_bills",
        "总库存" => "/warehouses/1/stocks"
        })
    end
  end
end