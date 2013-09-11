#encoding: utf-8
require 'spec_helper'

describe "Stocks" do
  login_admin

  let(:stock) { create(:stock_product,:product => create(:product),:account => current_account) }

  describe "GET /stocks" do
    it "works! (now write some real specs)" do
      get "/stocks"
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  describe "GET /stocks/old" do
    it "works! (now write some real specs)" do
      get "/stocks/old"
      response.status.should be(200)
    end
  end
  describe "GET /stocks/safe_stock" do
    it "works! (now write some real specs)" do
      get "/stocks/safe_stock"
      response.status.should be(200)
    end
  end
  describe "GET /stocks/change_product_type" do
    it "works! (now write some real specs)" do
      get "/stocks/change_product_type"
      response.status.should be(200)
    end
  end

  describe "GET /stocks/edit_depot" do
    it "works! (now write some real specs)" do
      get edit_depot_stocks_path
      response.status.should be(200)
    end
  end

  describe "POST /stocks/edit_safe_stock" do
    it "works! (now write some real specs)" do
      post "/stocks/edit_safe_stock", {id:stock.id}
      response.status.should be(200)
    end
  end

  describe "POST /stocks/batch_update_actual_stock" do

    it "works! (now write some real specs)" do
      post batch_update_actual_stock_stocks_path(:stock_product_ids => [stock.id],:actual => "a")
      flash[:error].should eq("请输入大于 0 的整数")
      expect(response).to redirect_to(stocks_path)
      response.status.should be(302)
    end

    pending "work" do
      post batch_update_actual_stock_stocks_path(:stock_product_ids => [stock.id],:actual => 1)
      expect(response).to redirect_to(stocks_path)
      flash[:notice].should eq("更新成功")
      response.status.should be(302)
    end
  end

  describe "POST /stocks/batch_update_safety_stock" do
    it "works! (now write some real specs)" do
      post batch_update_actual_stock_stocks_path(:stock_product_ids => [stock.id],:safe_value => 1)
      response.status.should be(302)
    end
  end
end
