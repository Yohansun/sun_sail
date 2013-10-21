# -*- encoding:utf-8 -*-
require "csv"


desc "核对淘宝数据"
task :fetch_taobao_data => :environment do
  total_pages = nil
  page_no = 0

  start_time = Time.local(2012,11,11,0,0,0)
  end_time = Time.now

  trade_source_id = 2
  CSV.open('result.csv', 'wb') do |csv|
  begin
    response = TaobaoQuery.get({
      method: 'taobao.trades.sold.get',
      type: 'fixed, auction, guarantee_trade, step, independent_simple_trade, independent_shop_trade, auto_delivery, ec, cod, game_equipment, shopex_trade, netcn_trade, external_trade, instant_trade, b2c_cod, hotel_trade, super_market_trade, super_market_cod_trade, taohua, waimai, nopaid, step, eticket, tmall_i18n, nopaid',
      fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
      start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
      page_no: page_no, page_size: 40}, trade_source_id
    )

    p "starting create_orders: since #{start_time}"

    unless response['trades_sold_get_response']
      p response
      break
    end

    total_results = response['trades_sold_get_response']['total_results'].to_i
    break if total_results < 1
    total_pages ||= total_results / 40
    trades = response['trades_sold_get_response']['trades']['trade']
    unless trades.is_a?(Array)
      trades = [] << trades
    end
    next if trades.blank?

    trades.each do |trade|
      orders = trade.delete('orders')
      local_trade = TaobaoTrade.where(tid: trade.tid).first

      unless trade
        puts "#{trade.tid} not found"
        csv << [trade.tid, "#{trade.tid} not found"]
        next
      end

      if local_trade.payment != trade.payment
        csv << [trade.tid, trade.payment, local_trade.payment]
      end

      # order = orders['order']

      # unless order.is_a?(Array)
      #   order = [] << order
      # end

      # order.each do |o|
      #   local_order = trade.taobao_orders.select{|order| order.outer_iid == o.outer_iid}
      # end
    end

    page_no += 1
  end until(page_no > total_pages || total_pages == 0)
  end
end
