#encoding: utf-8
require 'spec_helper'

describe "StockInBills" do
  login_admin
  let(:warehouse) { create(:seller,:account => current_account) }
  
  before(:each) do
    @warehouse = warehouse
    @stock_in_bill = create(:stock_in_bill,:account_id => current_account.id,:seller_id => @warehouse.id)
  end
  describe "GET /warehouses/1/stock_in_bills#index" do
    it "works! (now write some real specs)" do
      get warehouse_stock_in_bills_path(@warehouse)
      response.status.should be(200)
    end 
  end

  describe "GET /warehouses/1/stock_in_bills#new" do
    it "works! (now write some real specs)" do
      get new_warehouse_stock_in_bill_path(@warehouse)
      expect(response).to render_template(:new)
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#create" do
    it "should not be save" do
      post warehouse_stock_in_bills_path(@warehouse),{stock_in_bill: {key: "value"},warehouse_id: @warehouse.id,bill_product_ids: "1,2"}
      expect(response).to render_template(:new)
      response.status.should be(200)
    end

    it "should be save" do
      StockInBill.any_instance.stub(save: true)
      post warehouse_stock_in_bills_path(@warehouse),{stock_in_bill: {key: "value"},warehouse_id: @warehouse.id,bill_product_ids: "1,2"}
      expect(response).to redirect_to(warehouse_stock_in_bills_path(@warehouse))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  
  describe "GET /warehouses/1/stock_in_bills#edit" do
    it "works! (now write some real specs)" do
      get edit_warehouse_stock_in_bill_path(@warehouse,@stock_in_bill)
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
  end
  
  describe "GET /warehouses/1/stock_in_bills#show" do
    it "works! (now write some real specs)" do
      get warehouse_stock_in_bill_path(@warehouse,@stock_in_bill)
      expect(response).to render_template(:show)
      response.status.should be(200)
    end
  end
  
  describe "PUT /warehouses/1/stock_in_bills#update" do
    it "update failure" do
      StockInBill.any_instance.stub(update_attributes: false)
      put warehouse_stock_in_bill_path(@warehouse,@stock_in_bill),:bill_product_ids => '1,2'
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
    
    it "update success" do
      put warehouse_stock_in_bill_path(@warehouse,@stock_in_bill),:bill_product_ids => '1,2'
      expect(response).to redirect_to(warehouse_stock_in_bills_path(@warehouse))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#sync" do
    it "works! (now write some real specs)" do
      post sync_warehouse_stock_in_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_in_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#check" do
    it "works! (now write some real specs)" do
      post check_warehouse_stock_in_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_in_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#rollback" do
    it "works! (now write some real specs)" do
      post rollback_warehouse_stock_in_bills_path(@warehouse,:format => :js),:bill_ids => [@stock_in_bill.id]
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#add_product" do
    it "works! (now write some real specs)" do
      sku = create(:sku,:account_id => current_account.id,:product => create(:product,:account_id => current_account.id))
      post add_product_warehouse_stock_in_bills_path(@warehouse,:format => :js),:product => {:real_number => 1,:sku_id => sku.id,:number => 1,:total_price => 1}
      response.status.should be(200)
    end
  end
  
  describe "POST /warehouses/1/stock_in_bills#remove_product" do
    it "works! (now write some real specs)" do
      current_user.settings.stub(:tmp_products => [])
      post remove_product_warehouse_stock_in_bills_path(@warehouse,:format => :js)
      response.status.should be(200)
    end
  end
end