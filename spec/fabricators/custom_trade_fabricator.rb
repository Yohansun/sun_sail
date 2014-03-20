# -*- encoding : utf-8 -*-

Fabricator(:custom_trade) do
  available_confirm_fee      0.0
  buyer_cod_fee              0.0
  buyer_message              nil
  buyer_nick                 Faker::Lorem.characters(8)
  buyer_obtain_point_fee     0.0
  cod_fee                    0.0
  commission_fee             0.0
  created                    { sequence(:created)     {|i| Time.now - i.minutes } }
  credit_card_fee            0.0
  deliver_bills_count        0
  discount_fee               0.0
  express_agency_fee         0.0
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
  modify_payment             0.0
  pay_time                   { sequence(:pay_time)     {|i| Time.now - i.seconds } }
  total_fee                  { sequence(:total_fee)     {|i| 2130 - i*10 } }
  point_fee                  0.0
  post_fee                   { sequence(:post_fee)     {|i| 10 + i*5 } }
  price                      0.0
  promotion_details          []
  promotion_fee              0.0
  received_payment           0.0
  receiver_address           { sequence(:receiver_address)     {|i| "某路"+i.to_s+"栋XXX号" }}
  receiver_city              "北京"
  receiver_district          "北京市"
  receiver_mobile            { sequence(:receiver_mobile)     {|i| (Time.now.to_i.to_s + i.to_s).slice(0..10)}}
  receiver_name              Faker::Name.name
  receiver_phone             ""
  receiver_state             "西城区"
  receiver_zip               ""
  ref_batches                []
  seller_cod_fee             0.0
  splitted                   false
  status                     "WAIT_SELLER_SEND_GOODS"
  tid                        { sequence(:tid)     {|i| "CUSTOM" + Time.now.to_i.to_s + i.to_s } }
  unusual_states             []
  yfx_fee                    0.0

  after_create do |trade|

    trade.update_attributes(payment: trade.total_fee + trade.post_fee)

    trade.taobao_orders << Fabricate.build(:taobao_order)

    2.times do
      trade.operation_logs << Fabricate.build(:operation_log)
    end
  end
end