#encoding: utf-8
require 'spec_helper'

describe "StockOutBills" do
  login_admin
  let(:warehouse) { create(:seller,:account => current_account) }
  
  before(:each) do
    @warehouse = warehouse
    @stock_out_bill = create(:stock_out_bill,:account_id => current_account.id,:seller_id => @warehouse.id)
  end
  describe "GET /warehouses/1/stock_out_bills#index" do
    it "works! (now write some real specs)" do
      get warehouse_stock_out_bills_path(@warehouse)
      response.status.should be(200)
    end 
  end

  describe "GET /warehouses/1/stock_out_bills#new" do
    it "works! (now write some real specs)" do
      get new_warehouse_stock_out_bill_path(@warehouse)
      expect(response).to render_template(:new)
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#create" do
    it "should not be save" do
      post warehouse_stock_out_bills_path(@warehouse),{stock_out_bill: {key: "value"},warehouse_id: @warehouse.id,bill_product_ids: "1,2"}
      expect(response).to render_template(:new)
      response.status.should be(200)
    end

    it "should be save" do
      StockOutBill.any_instance.stub(save: true)
      post warehouse_stock_out_bills_path(@warehouse),{stock_out_bill: {key: "value"},warehouse_id: @warehouse.id,bill_product_ids: "1,2"}
      expect(response).to redirect_to(warehouse_stock_out_bills_path(@warehouse))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  
  describe "GET /warehouses/1/stock_out_bills#edit" do
    it "works! (now write some real specs)" do
      get edit_warehouse_stock_out_bill_path(@warehouse,@stock_out_bill)
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
  end
  
  describe "GET /warehouses/1/stock_out_bills#show" do
    it "works! (now write some real specs)" do
      get warehouse_stock_out_bill_path(@warehouse,@stock_out_bill)
      expect(response).to render_template(:show)
      response.status.should be(200)
    end
  end
  
  describe "PUT /warehouses/1/stock_out_bills#update" do
    #暂时没有编辑的功能
    pending "update failure" do
      StockOutBill.any_instance.stub(update_attributes: false)
      put warehouse_stock_out_bill_path(@warehouse,@stock_out_bill),:product_ids => '1,2'
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
    
    #暂时没有编辑的功能
    pending "update success" do
      put warehouse_stock_out_bill_path(@warehouse,@stock_out_bill),:product_ids => '1,2'
      expect(response).to redirect_to(warehouse_stock_out_bills_path(@warehouse))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#sync" do
    it "works! (now write some real specs)" do
      post sync_warehouse_stock_out_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_out_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#check" do
    it "works! (now write some real specs)" do
      post check_warehouse_stock_out_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_out_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#rollback" do
    it "works! (now write some real specs)" do
      post rollback_warehouse_stock_out_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_out_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#add_product" do
    it "works! (now write some real specs)" do
      sku = create(:sku,:account_id => current_account.id,:product => create(:product,:account_id => current_account.id))
      post add_product_warehouse_stock_out_bills_path(@warehouse,:format => :js),:product => {:real_number => 1,:sku_id => sku.id,:number => 1,:total_price => 1}
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_out_bills#remove_product" do
    it "works! (now write some real specs)" do
      current_user.settings.stub(:tmp_products => [])
      post remove_product_warehouse_stock_out_bills_path(@warehouse,:format => :js)
      response.status.should be(200)
    end
  end
end