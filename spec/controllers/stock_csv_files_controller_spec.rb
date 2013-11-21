# -*- encoding : utf-8 -*-
require 'spec_helper'

describe StockCsvFilesController do
  login_admin

  let(:warehouse) { FactoryGirl.create(:seller,:account_id => current_account.id) }
  let(:stock_csv_file) {FactoryGirl.create(:stock_csv_file, seller_id: warehouse.id)}
  before(:each) {
    warehouse
    stock_csv_file
  }

  describe "GET new" do
    it "assigns the requested stock_csv_file as @csv_file" do
      stock_csv_file.update_attributes(stock_in_bill_id: 123456)
      get :new,{:warehouse_id => warehouse}
      should respond_with 200
      should render_template :new
    end

    it "redirect to show if latest csv file has no stock_in_bill_id" do
      get :new,{:warehouse_id => warehouse}
      should respond_with 302
    end
  end

  describe "POST create" do
    before do
      @path = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/test.csv')))
    end
    it "show flash notice and render new if something wrong occured" do
      expect {
        stock_csv_file.update_attributes(stock_in_bill_id: 123456, used: false)
        post :create, {:stock_csv_file => {"path" => @path}, :warehouse_id => warehouse}
      }.to change(StockCsvFile, :count).by(0)
    end

    it "render show if everything is fine" do
      stock_csv_file.update_attributes(stock_in_bill_id: 123456, used: true)
      expect {
        post :create, {:stock_csv_file => {"path" => @path}, :warehouse_id => warehouse}
      }.to change(StockCsvFile, :count).by(1)
    end
  end

  describe "GET show" do
    it "render show" do
      StockCsvFile.any_instance.stub(:verify_stock_csv_file).and_return(["title",1,2])
      get :show, {warehouse_id: warehouse, id: stock_csv_file.id}
      assigns(:csv_info).count.should eq(2)
    end

    it "redirect to new" do
      StockCsvFile.any_instance.stub(:verify_stock_csv_file).and_return(nil)
      get :show, {warehouse_id: warehouse, id: stock_csv_file.id}
      should respond_with 302
    end

    it "redirect to /stock" do
      stock_csv_file.update_attributes(stock_in_bill_id: 123456)
      get :show, {warehouse_id: warehouse, id: stock_csv_file.id}
      should respond_with 302
    end
  end

  describe "PUT update" do
    before do
      product_1 = create(:product)
      stock_product_1 = create(:stock_product, product_id: product_1.id, account_id: current_account.id)
      sku_1 = create(:sku, stock_product_ids: [stock_product_1.id])
      product_2 = create(:product)
      stock_product_2 = create(:stock_product, product_id: product_2.id, account_id: current_account.id)
      sku_2 = create(:sku, stock_product_ids: [stock_product_2.id])
    end
    it "generate associate stock in bill and redirect to /stock" do
      expect {
        put :update, {warehouse_id: warehouse, id: stock_csv_file.id}
      }.to change(StockInBill, :count).by(1)
      assigns(:csv_file).stock_in_bill_id.should_not be_empty
      should respond_with 302
    end
  end

  describe "DELETE destroy" do
    it "delete current csv file and redirect to /stock" do
      delete :destroy, {warehouse_id: warehouse, id: stock_csv_file.id}
      assigns(:csv_file).should eq(stock_csv_file)
      should respond_with 302
    end
  end

end
