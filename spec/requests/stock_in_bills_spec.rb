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
      post warehouse_stock_in_bills_path(@warehouse),{stock_in_bill: {key: "value"},warehouse_id: @warehouse.id}
      expect(response).to render_template(:new)
      response.status.should be(200)
    end

    it "should be save" do
      #StockInBill.any_instance.stub(save: true)
      post warehouse_stock_in_bills_path(@warehouse),{stock_in_bill: {stock_type: "IIR",
        bill_products_attributes:{"0"=>{sku_id:666,number:200,price:16,real_number:200,total_price:3200}}
      }}
      expect(response).to redirect_to(warehouse_stock_in_bill_path(@warehouse.id,assigns(:bill).id))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:show)
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
      StockInBill.any_instance.stub(save: false)
      put warehouse_stock_in_bill_path(@warehouse,@stock_in_bill)
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
    
    it "update success" do
      StockInBill.any_instance.stub(save: true)
      put warehouse_stock_in_bill_path(@warehouse,@stock_in_bill)
      expect(response).to redirect_to(warehouse_stock_in_bill_path(@warehouse,@stock_in_bill))
      response.status.should be(302)
      follow_redirect!
      expect(response).to render_template(:show)
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
end