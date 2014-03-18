# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CustomTradesController do
  login_admin

  let(:product){create(:product, account_id: current_account.id)}
  let(:sku){create(:sku, product: product, account_id: current_account.id)}
  let(:custom_trade){create(:custom_trade, account_id: current_account.id)}

  before(:each) {
    custom_trade
    product
    sku
    @area_ids = []
    area_sample = [["110000", "北京"],["110100","北京市"],["110102","朝阳区"]]
    area_sample.each_with_index do |data, index|
      if index == 0
        create(:area, id: data[0].to_i, name: data[1], parent_id: nil)
      else
        create(:area, id: data[0].to_i, name: data[1], parent_id: area_sample[index - 1][0])
      end
    end
  }

  def valid_session
    {}
  end

  describe "GET new" do
    it "assigns a new custom_trade as @custom_trade" do
      get :new
      assigns(:custom_trade).should be_a_new(CustomTrade)
    end
  end

  describe "POST create" do
    context "has order params" do
      it "should create new trade with valid params" do
        valid_params = {
          "custom_trade" => {
            tid: "TEST00000000001",
            receiver_name: "测试人名",
            receiver_mobile: "13999999999",
            receiver_state: "110000",
            receiver_city: "110100",
            receiver_district: "110102",
            receiver_address: "测试地址",
            created: Time.now,
            pay_time: Time.now,
            status: "WAIT_SELLER_SEND_GOODS"
          },
          "taobao_orders" => ["#{product.outer_id};0;1;234;测试商品"]# ["淘宝商品编码;Sku编码;数量;价格;名称"]
        }
        expect {
          post :create, {:custom_trade => valid_params['custom_trade'], :taobao_orders=>valid_params['taobao_orders']}
        }.to change(CustomTrade, :count).by(1)
        should redirect_to "/app#trades"
      end

      it "should render new with invalid params" do
        invalid_params = {
          "custom_trade" => {
            tid: "TEST00000000001",
            receiver_name: "",
            receiver_mobile: "13999999999",
            receiver_state: "110000",
            receiver_city: "110100",
            receiver_district: "110102",
            receiver_address: "测试地址",
            created: Time.now,
            pay_time: Time.now,
            status: "WAIT_SELLER_SEND_GOODS"
          },
          "taobao_orders" => ["#{product.outer_id};0;1;234;测试商品"]# ["淘宝商品编码;Sku编码;数量;价格;名称"]
        }
        expect {
          post :create, {:custom_trade => invalid_params['custom_trade'], :taobao_orders=> invalid_params['taobao_orders']}
        }.to change(CustomTrade, :count).by(0)
        should respond_with 200
      end
    end

    context "without order params" do
      it "should render new" do
        invalid_params = {
          "custom_trade" => {
            tid: "TEST00000000001",
            receiver_name: "",
            receiver_mobile: "13999999999",
            receiver_state: "110000",
            receiver_city: "110100",
            receiver_district: "110102",
            receiver_address: "测试地址",
            created: Time.now,
            pay_time: Time.now,
            status: "WAIT_SELLER_SEND_GOODS"
          },
        }
        expect {
          post :create, {:custom_trade => invalid_params['custom_trade'], :taobao_orders=> invalid_params['taobao_orders']}
        }.to change(CustomTrade, :count).by(0)
        should respond_with 200
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested custom_trade as @custom_trade" do
      get :edit, {id: custom_trade.id}, valid_session
      assigns(:custom_trade).should eq(custom_trade)
    end
  end

  describe "PUT update" do
    it "updates the requested custom_trade" do
      put :update, {id: custom_trade.id, custom_trade: {}}, valid_session
      should respond_with 200
    end
  end

  describe "GET change_products" do
    it "render change_products" do
      get :change_products, {outer_id: product.outer_id}, valid_session
      parsed_body = JSON.parse(response.body)
      parsed_body['skus'][0]['sku_id'].should eq(sku.id)
      should respond_with 200
    end
  end

end