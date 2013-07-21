# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Trades" do
  login_admin



  describe "GET /trades" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      xhr :get, trades_path(:json)
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"my_trade")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"undispatched")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"delivered")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"undelivered")
      response.status.should be(200)

      xhr :get, trades_path(trade_type:"unusual_all")
      response.status.should be(200)
    end
  end

  describe "export" do
    it "should works" do
      xhr :get, export_trades_path
      response.status.should eq(200)
    end
  end

  describe "notifier" do
    it "should works" do
      xhr :get, notifer_trades_path(trade_type:"taobao")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"taobao_fenxiao")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"jingdong")
      response.status.should eq(200)

      xhr :get, notifer_trades_path(trade_type:"shop")
      response.status.should eq(200)

      xhr :get, notifer_trades_path
      response.status.should eq(200)

    end
  end


  describe "show json" do
    it "should works" do
      xhr :get, trade_path(trade)
      response.status.should eq(200)
      JSON.parse(response.body)["id"].should eq(trade.id.to_s)
    end
  end


  describe "update" do
    it "should works" do
      xhr :put, trade_path(trade),{
        cs_memo:"cs memo"
      }
      response.status.should eq(200)
      Trade.find(trade.id).cs_memo.should eq("cs memo")


      # TODO: add more attribute changes for trade, to covert more controller code
    end
  end


  describe "batch check goods" do
    it "should success" do
      xhr :get, "/trades/batch_check_goods", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "batch export" do
    it "should success" do
      xhr :get, "/trades/batch_export", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "verify add gift" do
    it "should success" do
      xhr :get, "/trades/verify_add_gift", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "batch add gift" do
    it "should success" do
      xhr :get, "/trades/batch_add_gift", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  describe "lock and activate" do
    it "should success" do
      xhr :get, "/trades/lock_trade", id:trade.id.to_s
      response.status.should eq(200)
      trade.reload.is_locked.should eq(true)
      xhr :get, "/trades/activate_trade", id:trade.id.to_s
      response.status.should eq(200)
      trade.reload.is_locked.should eq(false)
    end
  end

  describe "get seller info" do
    pending "should success" do
      xhr :get, "/trades/#{trade.id}/sellers_info.json"
      response.status.should eq(200)
    end
  end

  describe "split and merge" do
    it "should success" do
      xhr :get, "trades/split/#{trade.id}"
      response.status.should eq(200)

      #TODO: merge splitted trades
    end
  end


  describe "batch deliver" do
    it "should success" do
      xhr :get, "/trades/batch_deliver",  ids:[trade.id.to_s]
      response.status.should eq(200)
      trade.reload.status.should == "WAIT_BUYER_CONFIRM_GOODS"
    end
  end

  describe "get deliver list" do
    it "should success" do
      xhr :get, "/trades/deliver_list", ids:[trade.id.to_s]
      response.status.should eq(200)
    end
  end


  let(:trade){create(:trade,
{"_id"=>"51e7c828046d5077b8000002",
 "_type"=>"Trade",
 "account_id"=>current_account.id,
 "available_confirm_fee"=>0.0,
 "buyer_cod_fee"=>0.0,
 "buyer_message"=>nil,
 "buyer_nick"=>nil,
 "buyer_obtain_point_fee"=>0.0,
 "cod_fee"=>0.0,
 "commission_fee"=>0.0,
 "created"=>Time.new("2013-07-18 08:40:00 UTC"),
 "created_at"=>"2013-07-18 10:49:12 UTC",
 "credit_card_fee"=>0.0,
 "cs_memo"=>nil,
 "deliver_bills_count"=>1,
 "delivered_at"=>"2013-07-19 06:26:51 UTC",
 "discount_fee"=>0.0,
 "dispatched_at"=>"2013-07-18 11:00:34 UTC",
 "express_agency_fee"=>0.0,
 "gift_memo"=>nil,
 "got_promotion"=>false,
 "has_color_info"=>false,
 "has_cs_memo"=>false,
 "has_invoice_info"=>false,
 "has_onsite_service"=>false,
 "has_post_fee"=>0.0,
 "has_refund_orders"=>false,
 "has_split_deliver_bill"=>false,
 "has_unusual_state"=>false,
 "invoice_name"=>"个人",
 "invoice_type"=>"需要开票",
 "is_auto_deliver"=>false,
 "is_auto_dispatch"=>false,
 "is_locked"=>false,
 "logistic_code"=>"OTHER",
 "logistic_id"=>105,
 "logistic_name"=>"韵达",
 "logistic_waybill"=>"123456",
 "merged_trade_ids"=>["51e7c5d4046d500263000005", "51e7c648046d50026300000a"],
 "modify_payment"=>0.0,
 "operation_logs"=>
  [{"_id"=>"51e8a6a4046d5060b0000004",
    "operated_at"=>"2013-07-19 02:38:28 UTC",
    "operator"=>"brands_admin",
    "operator_id"=>5366,
    "operation"=>"申请开票",
    "updated_at"=>"2013-07-19 02:38:28 UTC",
    "created_at"=>"2013-07-19 02:38:28 UTC"},
   {"_id"=>"51e8a6ad046d5060b0000005",
    "operated_at"=>"2013-07-19 02:38:37 UTC",
    "operator"=>"brands_admin",
    "operator_id"=>5366,
    "operation"=>"确认开票",
    "updated_at"=>"2013-07-19 02:38:37 UTC",
    "created_at"=>"2013-07-19 02:38:37 UTC"},
   {"_id"=>"51e8dc2b046d50f321000001",
    "operated_at"=>"2013-07-19 06:26:51 UTC",
    "operator"=>"admin",
    "operator_id"=>1,
    "operation"=>"订单发货",
    "updated_at"=>"2013-07-19 06:26:51 UTC",
    "created_at"=>"2013-07-19 06:26:51 UTC"}],
 "pay_time"=>"2013-07-18 08:40:00 UTC",
 "payment"=>10.0,
 "point_fee"=>0.0,
 "post_fee"=>0.0,
 "price"=>0.0,
 "promotion_details"=>[],
 "promotion_fee"=>0.0,
 "received_payment"=>0.0,
 "receiver_address"=>"史蒂文大厦",
 "receiver_city"=>"北京市",
 "receiver_district"=>"东城区",
 "receiver_mobile"=>"13822222222",
 "receiver_name"=>"史蒂文",
 "receiver_phone"=>"",
 "receiver_state"=>"北京",
 "receiver_zip"=>"",
 "ref_batches"=>[],
 "seller_cod_fee"=>0.0,
 "seller_confirm_invoice_at"=>"2013-07-19 02:38:37 UTC",
 "seller_id"=>2,
 "seller_memo"=>nil,
 "seller_name"=>"白兰氏经销商",
 "splitted"=>false,
 "status"=>"WAIT_BUYER_CONFIRM_GOODS",
 "taobao_orders"=>
  [{"_id"=>"51e7c5d4046d500263000006",
    "color_num"=>[],
    "color_hexcode"=>[],
    "color_name"=>[],
    "barcode"=>[],
    "_type"=>"TaobaoOrder",
    "price"=>95.0,
    "total_fee"=>0.0,
    "payment"=>2.0,
    "discount_fee"=>0.0,
    "oid"=>"0000222222222222",
    "status"=>"WAIT_SELLER_SEND_GOODS",
    "refund_status"=>"NO_REFUND",
    "seller_type"=>"B",
    "num_iid"=>"8637312138",
    "sku_id"=>"",
    "num"=>1,
    "title"=>"白兰氏 传统鸡精 抗疲劳增强抵抗力 益智补脑提高免疫力 1盒",
    "cid"=>50026809,
    "pic_path"=>
     "http://img03.taobaocdn.com/bao/uploaded/i3/17005024601551028/T1RgFpFkpaXXXXXXXX_!!0-item_pic.jpg"},
   {"_id"=>"51e7c5d4046d500263000007",
    "color_num"=>[],
    "color_hexcode"=>[],
    "color_name"=>[],
    "barcode"=>[],
    "_type"=>"TaobaoOrder",
    "price"=>86.0,
    "total_fee"=>0.0,
    "payment"=>4.0,
    "discount_fee"=>0.0,
    "oid"=>"0000222222222222",
    "status"=>"WAIT_SELLER_SEND_GOODS",
    "refund_status"=>"NO_REFUND",
    "seller_type"=>"B",
    "num_iid"=>"16863181884",
    "sku_id"=>"",
    "num"=>2,
    "title"=>"白兰氏 水润美肤尝鲜组合 纤梅饮3瓶装+胶原蛋白果冻2条 特惠装",
    "cid"=>50026858,
    "pic_path"=>
     "http://img04.taobaocdn.com/bao/uploaded/i4/17005036504680223/T1E2XpFfXbXXXXXXXX_!!0-item_pic.jpg"},
   {"_id"=>"51e7c648046d50026300000b",
    "color_num"=>[],
    "color_hexcode"=>[],
    "color_name"=>[],
    "barcode"=>[],
    "_type"=>"TaobaoOrder",
    "price"=>136.0,
    "total_fee"=>0.0,
    "payment"=>2.0,
    "discount_fee"=>0.0,
    "oid"=>"1111222233334444",
    "status"=>"WAIT_SELLER_SEND_GOODS",
    "refund_status"=>"NO_REFUND",
    "seller_type"=>"B",
    "num_iid"=>"16468541391",
    "sku_id"=>nil,
    "num"=>1,
    "title"=>"白兰氏 排毒美白套装 纤梅饮6瓶装+胶原蛋白果冻2条装 特惠装",
    "cid"=>50026858,
    "pic_path"=>
     "http://img01.taobaocdn.com/bao/uploaded/i1/17005024608010909/T1q64qFfpXXXXXXXXX_!!0-item_pic.jpg"},
   {"_id"=>"51e7c648046d50026300000c",
    "color_num"=>[],
    "color_hexcode"=>[],
    "color_name"=>[],
    "barcode"=>[],
    "_type"=>"TaobaoOrder",
    "price"=>456.0,
    "total_fee"=>0.0,
    "payment"=>2.0,
    "discount_fee"=>0.0,
    "oid"=>"1111222233334444",
    "status"=>"WAIT_SELLER_SEND_GOODS",
    "refund_status"=>"NO_REFUND",
    "seller_type"=>"B",
    "num_iid"=>"13698053445",
    "sku_id"=>nil,
    "num"=>2,
    "title"=>"白兰氏 抗氧化套装 纤梅饮14天装+馥莓饮14天装  特惠装",
    "cid"=>50026904,
    "pic_path"=>
     "http://img04.taobaocdn.com/bao/uploaded/i4/17005036511252284/T1stXqFe8aXXXXXXXX_!!0-item_pic.jpg"}],
 "tid"=>"HB1374144552295",
 "total_fee"=>1315.0,
 "trade_gifts"=>[],
 "unusual_states"=>[],
 "updated_at"=>"2013-07-19 06:26:51 UTC",
 "yfx_fee"=>0.0}

    )}
end
