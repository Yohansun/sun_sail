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
    it "show flash notice and render new if something wrong occured" do
    end

    it "render show if everything is fine" do
    end
  end

  describe "GET show" do
    it "render show" do
    end

    it "redirect to /stock" do
    end
  end

  describe "PUT update" do
    it "generate associate stock in bill and redirect to /stock" do
    end
  end

  describe "DELETE destroy" do
    it "delete current csv file and redirect to /stock" do
    end
  end

end
