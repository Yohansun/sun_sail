#encoding: utf-8
require 'spec_helper'

describe StocksController do
  login_admin

  let(:active_stock) {create(:stock_product,:actual => 2,:activity => 1,:product => create(:product),:account => current_account, :seller => create(:seller, :active => true ))}
  let(:closed_stock) {create(:stock_product,:actual => 2,:activity => 1,:product => create(:product),:account => current_account, :seller => create(:seller, :active => false ))}

  before(:each) { active_stock }
  before(:each) { closed_stock }
  def valid_attributes
    {  }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CustomersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all stocks as @stock_products" do
      get :index,{}, valid_session
      assigns(:stock_products).to_a.should eq([active_stock])
    end
  end

  describe "GET batch_update_safety_stock" do
    it "assigns safe_values as @stock_products" do
      post :batch_update_safety_stock,{:stock_product_ids => [active_stock.id],:safe_value => 999}, valid_session
      assigns(:stock_products).map(&:safe_value).uniq.should eq([999])
      response.should redirect_to stocks_path
    end
  end

  describe "GET batch_update_actual_stock" do
    pending "Success" do
      post :batch_update_actual_stock,{:stock_product_ids => [active_stock.id],:actual => 888}, valid_session
      assigns(:stock_products).map(&:actual).uniq.should eq([888])
      flash[:notice].should == "更新成功"
      response.should redirect_to stocks_path
    end
    it "Failure" do
      post :batch_update_actual_stock,{:stock_product_ids => [active_stock.id],:actual => "0a"}, valid_session
      flash[:error].should == "请输入大于 0 的整数"
      assigns(:stock_products).map(&:actual).uniq.should eq([1])
      response.should redirect_to stocks_path
    end
  end
end
