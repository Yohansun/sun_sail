# -*- encoding : utf-8 -*-
class TradeChecker
  def self.taobao_trade_status(start_time = nil, end_time = nil, trade_source_id = nil, send_email = true)
    # 抓取最近 37 ~ 1 小时订单, 检查本地状态和淘宝状态是否匹配
    
    if start_time.blank?
      start_time = Time.now - 37.hours
    end

    if end_time.blank?
      end_time = Time.now - 1.hour
    end
    
    if trade_source_id.blank?
      trade_source_id = TradeSetting.default_taobao_trade_source_id
    end 

    Rails.logger.info "starting check_status: since #{start_time}"
    puts "starting check_status: since #{start_time}"

    lost_orders = []
    wrong_orders = []
    has_next = true
    page_no = 1
    while has_next
      Rails.logger.info "check_status: fetching page #{page_no}"
      puts "check_status: fetching page #{page_no}"
      
     response = TaobaoQuery.get({
        method: 'taobao.trades.sold.get',
        fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: page_no, page_size: 80}, trade_source_id 
      ) 

      page_no += 1
      has_next = response['trades_sold_get_response']['has_next'] || false
      next unless response['trades_sold_get_response']['trades']
      trades = response['trades_sold_get_response']['trades']['trade']
      unless trades.is_a?(Array)
        trades = [] << trades
      end  
      next if trades.blank?
      
      trades.each do |trade|
        tid = trade['tid'].to_s
        if TaobaoTrade.where(tid: trade['tid']).exists?
          local_trade = TaobaoTrade.only(:status).where(tid: tid).first
          if local_trade.status != trade['status']
            # ERROR: 状态有误
            wrong_orders << tid
          end
        else
          # ERROR: 漏掉订单
          lost_orders << tid
        end
      end
    end

    Rails.logger.info "ending check_status: ERROR lost #{lost_orders.join(",")}"
    puts "ending check_status: ERROR lost #{lost_orders.join(",")}"

    Rails.logger.info "ending check_status: ERROR wrong #{wrong_orders.join(",")}"
    puts "ending check_status: ERROR wrong #{wrong_orders.join(",")}"

    bad_status_orders = TaobaoTrade.only(:tid, :status, :track_goods_status).where(:status.in => ["WAIT_SELLER_SEND_GOODS"], :track_goods_status.in => ["INIT"]).all.map { |e| e.tid }
    
    hidden_orders = TaobaoTrade.only(:tid, :has_buyer_message, :buyer_message).where(has_buyer_message: true, buyer_message:nil).map(&:tid)
    
    if send_email
      DailyOrdersNotifier.check_status_result(start_time, end_time, lost_orders, wrong_orders, bad_status_orders, hidden_orders).deliver
    end
  end

end
