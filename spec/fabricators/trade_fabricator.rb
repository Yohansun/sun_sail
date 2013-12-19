# -*- encoding : utf-8 -*-

Fabricator(:trade) do
  available_confirm_fee      0.0
  buyer_cod_fee              0.0
  buyer_message              nil
  buyer_nick                 nil
  buyer_obtain_point_fee     0.0
  cod_fee                    0.0
  commission_fee             0.0
  created                    Time.new("2013-07-18 08:40:00 UTC")
  created_at                 "2013-07-18 10:49:12 UTC"
  credit_card_fee            0.0
  cs_memo                    nil
  deliver_bills_count        1
  delivered_at               "2013-07-19 06:26:51 UTC"
  discount_fee               0.0
  dispatched_at              "2013-07-18 11:00:34 UTC"
  express_agency_fee         0.0
  gift_memo                  nil
  got_promotion              false
  has_color_info             false
  has_cs_memo                false
  has_invoice_info           false
  has_onsite_service         false
  has_post_fee               0.0
  has_refund_orders          false
  has_split_deliver_bill     false
  has_unusual_state          false
  invoice_name               "个人"
  invoice_type               "需要开票"
  is_auto_deliver            false
  is_auto_dispatch           false
  is_locked                  false
  logistic_code              "OTHER"
  logistic_id                105
  logistic_name              "韵达"
  logistic_waybill           "123456"
  merged_trade_ids           ["51e7c5d4046d500263000005", "51e7c648046d50026300000a"]
  modify_payment             0.0
  pay_time                   "2013-07-18 08:40:00 UTC"
  payment                    10.0
  point_fee                  0.0
  post_fee                   0.0
  price                      0.0
  promotion_details          []
  promotion_fee              0.0
  received_payment           0.0
  receiver_address           "史蒂文大厦"
  receiver_city              "北京市"
  receiver_district          "东城区"
  receiver_mobile            "13822222222"
  receiver_name              "史蒂文"
  receiver_phone             ""
  receiver_state             "北京"
  receiver_zip               ""
  ref_batches                []
  seller_cod_fee             0.0
  seller_confirm_invoice_at  "2013-07-19 02:38:37 UTC"
  seller_id                  2
  seller_memo                nil
  seller_name                "白兰氏经销商"
  splitted                   false
  status                     "WAIT_BUYER_CONFIRM_GOODS"
  tid                        "HB1374144552295"
  total_fee                  1315.0
  unusual_states             []
  updated_at                 "2013-07-19 06:26:51 UTC"
  yfx_fee                    0.0

  after_create do |trade|
    4.times do
      trade.taobao_orders << Fabricate.build(:taobao_order)
    end

    3.times do
      trade.operation_logs << Fabricate.build(:operation_log)
    end
  end
end