# encoding : utf-8 -*-
class TaobaoTradePuller
  extend Bm
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find(account_id)
      page_no = 1

      if start_time.blank?
        if TaobaoTrade.where(account_id: account_id,trade_source_id: trade_source_id).count > 1
          latest_created_order = TaobaoTrade.only(:created, :account_id,:trade_source_id).where(account_id: account_id,trade_source_id: trade_source_id).order_by(:created.desc).limit(1).first
          start_time = latest_created_order.created - 1.hour
        else
          start_time = Time.now - 1.month
        end
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.taobao_trade_created_boundary.to_time(:local) rescue nil
      if created_boundary.respond_to?(:to_time)
        if created_boundary > start_time
          start_time = created_boundary
        end
      end

      if end_time.blank?
        end_time = Time.now
      end

      console_hash = {account_id: account_id, start_at: start_time,end_at: end_time}
      logger.info("[ready] " << console_hash.collect{|x,y| "#{x}:#{y}"}.join(" "))
      has_next = true
      results = 0
      handles = 0
      exists = []
      while has_next
        has_next = false
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          type: 'fixed,auction,guarantee_trade,step,independent_simple_trade,independent_shop_trade,auto_delivery,ec,cod,game_equipment,shopex_trade,netcn_trade,external_trade,instant_trade,b2c_cod,hotel_trade,super_market_trade,super_market_cod_trade,taohua,waimai,nopaid,eticket,tmall_i18n',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no,
          page_size: 100,
          use_has_next: true}, trade_source_id
          )

        unless response['trades_sold_get_response']
          Notifier.puller_errors(response, account_id).deliver
          break
        end

        page_no += 1
        has_next = response['trades_sold_get_response']['has_next']
        next unless response['trades_sold_get_response']['trades']


        trades = response['trades_sold_get_response']['trades']['trade']
        tids = trades.collect {|t| t["tid"].to_s}
        results += tids.length
        exists_tids = TaobaoTrade.unscoped.only(:tid).where(:tid.in => tids).distinct(:tid)
        exists << exists_tids
        news_tids = tids - exists_tids

        trades = trades.reject {|trade| !news_tids.include?(trade["tid"].to_s)}.each do |trade|
          trade["taobao_orders"] = trade.delete("orders")["order"]
          trade["trade_source_id"] = trade_source_id
          trade["news"] = 3
          trade["account_id"] = account.id
        end

        trades = trades.collect {|trade|
          t = TaobaoTrade.new(trade)
          t.attributes.merge(taobao_orders: t.taobao_orders.map(&:attributes))
        }

        Trade.collection.insert(trades)
        handles += trades.length

        TaobaoPullerBuilder.perform_async(trade_source_id)
      end

      console_hash.merge({results: results,handles: handles,exists: exists.flatten})
    end

    def create_by_tid(tid, trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find(account_id)

      response = TaobaoQuery.get({
        method: 'taobao.trade.fullinfo.get', tid: tid,
        fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        }, trade_source_id
      )

      trade = response['trade_fullinfo_get_response']['trade']
      return if trade.blank?
      return if ($redis.sismember('TaobaoTradeTids',trade['tid']) || TaobaoTrade.unscoped.where(tid: trade['tid']).exists?)
      create_trade(trade, account, trade_source_id)
    end

    def create_trade(trade, account, trade_source_id)
      orders = trade.delete('orders')
      trade = TaobaoTrade.new(trade)
      trade.trade_source_id = trade_source_id
      trade.account_id = account.id
      order = orders['order']

      unless order.is_a?(Array)
        order = [] << order
      end

      order.each do |o|
        taobao_order = trade.taobao_orders.build(o)
      end

      if trade.save
        SetForecastSellerWorker.perform_async(trade.id)
        SetHasOnsiteServiceWorker.perform_async(trade.id) if account.settings.enable_module_onsite_service == 1
        SetAlipayDataWorker.perform_async(trade.id) if trade.status == "TRADE_FINISHED"
        SetTradeOperator.perform_async(trade.id)
        TradeTaobaoMemoFetcher.perform_async(trade.tid)
        TradeTaobaoPromotionFetcher.perform_async(trade.tid)
        $redis.sadd('TaobaoTradeTids',trade['tid'])
        trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取订单')

        if account.settings.auto_settings['auto_dispatch']
          result = account.can_auto_dispatch_right_now
          DelayAutoDispatch.perform_in((result == true ?  account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), trade.id)
        end
      end
    end

    def update_end_time
      trades = Trade.where(end_time: nil).and(status: 'TRADE_FINISHED')
      trades.each do |trade|
        response = TaobaoQuery.get({method: 'taobao.trade.get', fields: 'end_time', tid: trade.tid}, trade.trade_source_id)
        if response["trade_get_response"] && response["trade_get_response"]["trade"] && response["trade_get_response"]["trade"]["end_time"]
          trade.update_attributes(end_time: response["trade_get_response"]["trade"]["end_time"])
        end
      end
    end

    def update(start_time = nil, end_time = nil, trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find(account_id)

      if start_time.blank?
        if TaobaoTrade.where(account_id: account_id).count > 1
          latest_created_order = TaobaoTrade.only(:modified, :account_id,:trade_source_id).where(trade_source_id: trade_source_id,account_id: account_id).order_by(:modified.desc).limit(1).first
          start_time = latest_created_order.modified - 4.hour
        else
          start_time = Time.now - 1.month
        end
      end

      if end_time.blank?
        end_time = start_time + 1.day
      end

      #start_modified-and-end_modified, 查询条件(修改时间)跨度不能超过一天
      time_range_digist = end_time - start_time
      days = 0
      days = (time_range_digist/86400).floor

      (0..days).each do |num|
        range_begin  = start_time + num.days
        range_end = start_time + 1.day + num.days
        page_no = 1
        has_next = true
        while has_next
          has_next = false
          response = TaobaoQuery.get({:method => 'taobao.trades.sold.increment.get',
            :fields => 'total_fee, tid, status, adjust_fee, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, title, type, point_fee, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
            :start_modified => range_begin.strftime("%Y-%m-%d %H:%M:%S"),
            :end_modified => range_end.strftime("%Y-%m-%d %H:%M:%S"),
            :page_no => page_no,
            :page_size => 40,
            :use_has_next => true}, trade_source_id
            )

          page_no += 1
          has_next = response['trades_sold_increment_get_response']['has_next']
          next unless response['trades_sold_increment_get_response']['trades']

          trades = response['trades_sold_increment_get_response']['trades']['trade']
          unless trades.is_a?(Array)
            trades = [] << trades
          end
          next if trades.blank?

          trades.each do |trade|
            update_trade(trade, account, trade_source_id)
          end
        end
      end
      #同步本地顾客管理下面的"副本订单"
      CustomerFetch.perform_async(trade_source.id,"TaobaoTrade")
    end

    def update_by_tid(trade)
      trade_source_id = trade.trade_source_id
      tid = trade.tid
      account = trade.fetch_account
      account_id = account.id
      response = TaobaoQuery.get({
        method: 'taobao.trade.fullinfo.get',
        fields: 'total_fee, tid, status, adjust_fee, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, title, type, point_fee, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        tid: tid}, trade_source_id
      )
      trade = response['trade_fullinfo_get_response']['trade']
      update_trade(trade, account, trade_source_id)
    end

    def updatable?(local_trade, remote_status, has_refund_status)
      has_refund_status || !local_trade.splitted || (local_trade.splitted && remote_status != local_trade.status && remote_status != "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.blank?)
    end

    def update_trade(trade, account, trade_source_id)
      TaobaoTrade.where(tid: trade['tid']).each do |local_trade|

        trade_old_status = local_trade.status
        orders = trade.delete('orders').delete('order')

        has_refund_status = (orders.map {|x| x.fetch('refund_status')}.uniq - ["NO_REFUND"]).present?
        next unless updatable?(local_trade, trade['status'], has_refund_status)

        trade['trade_source_id'] = trade_source_id
        local_trade.update_attributes(trade)

        unless orders.is_a?(Array)
          orders = [] << orders
        end

        orders.each do |order|
          local_order = local_trade.orders.where(oid: order['oid']).first
          if local_order
            local_order.update_attributes(order)
          else
            response = "--#{account.key}---#{local_trade.tid}----#{order['oid']}---"
            Notifier.puller_errors(response, account.id).deliver
          end
        end

        if local_trade.changed?
          local_trade.operation_logs.build(operated_at: Time.now, operation: "从淘宝更新订单,更新#{local_trade.changed.try(:join, ',')}")
          local_trade.news = 1
        end
        SetHasOnsiteServiceWorker.perform_async(local_trade.id) if account.settings.enable_module_onsite_service == 1
        SetAlipayDataWorker.perform_async(local_trade.id) if local_trade.status == "TRADE_FINISHED"
        SetForecastSellerWorker.perform_async(local_trade.id) if local_trade.forecast_seller_id.nil?
        local_trade.save

        if account.settings.auto_settings['auto_dispatch']
          result = account.can_auto_dispatch_right_now
          DelayAutoDispatch.perform_in((result == true ? account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), local_trade.id)
        end

        TradeTaobaoMemoFetcher.perform_async(local_trade.tid)
        TradeTaobaoPromotionFetcher.perform_async(local_trade.tid)
      end
    end

    def update_by_created(start_time = nil, end_time = nil, trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find(trade_source.account_id)

      if start_time.blank?
        latest_created_order = TaobaoTrade.only(:created, :account_id).where(account_id: account_id).order_by(:created.desc).limit(1).first
        start_time = latest_created_order.created - 1.hour
      end

      if end_time.blank?
        end_time = Time.now
      end

      page_no = 1
      has_next = true
      while has_next
        has_next = false
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          type: 'fixed, auction, guarantee_trade, step, independent_simple_trade, independent_shop_trade, auto_delivery, ec, cod, game_equipment, shopex_trade, netcn_trade, external_trade, instant_trade, b2c_cod, hotel_trade, super_market_trade, super_market_cod_trade, taohua, waimai, nopaid, eticket, tmall_i18n',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no,
          page_size: 40,
          :use_has_next => true}, trade_source_id
          )

        page_no += 1
        has_next = response['trades_sold_get_response']['has_next']
        next unless response['trades_sold_get_response']['trades']

        trades = response['trades_sold_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end

        next if trades.blank?

        trades.each do |trade|
          update_trade(trade, account, trade_source_id)
        end
      end
      CustomerFetch.perform_async(trade_source.id,"TaobaoTrade")
    end

    def logger
      @logger ||= MagicLogger.new(Rails.root.join("log/taobao_trade_puller.log"))
    end

    def create_with_benchmark(*args)
      benchmark("create",result: true) { create_without_benchmark(*args) }
    end

    alias_method_chain :create,:benchmark
  end
end
