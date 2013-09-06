# encoding : utf-8 -*-
class TaobaoTradePuller
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id)
      total_pages = nil
      page_no = 1

      trade_source = TradeSource.find_by_id(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find_by_id(account_id)
      # 给客服分配定单需要的查询
      users = account.users.where(can_assign_trade: true).where(active: true).order(:created_at) rescue nil
      if users
        total_percent = users.inject(0) { |sum, el| sum += el.trade_percent.to_i }
      end

      if start_time.blank?
        if TaobaoTrade.where(account_id: account_id).count > 1
          latest_created_order = TaobaoTrade.only(:created, :account_id).where(account_id: account_id).order_by(:created.desc).limit(1).first
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

      begin
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 40}, trade_source_id
          )

        unless response['trades_sold_get_response']
          Notifier.puller_errors(response, account_id).deliver
          return
        end

        total_results = response['trades_sold_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 40
        next if total_results < 1
        trades = response['trades_sold_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end
        next if trades.blank?

        trades.each do |trade|

          next if ($redis.sismember('TaobaoTradeTids',trade['tid']) || TaobaoTrade.unscoped.where(tid: trade['tid']).exists?)
          orders = trade.delete('orders')
          trade = TaobaoTrade.new(trade)

          trade.trade_source_id = trade_source_id

          trade.account_id = account_id

          order = orders['order']

          unless order.is_a?(Array)
            order = [] << order
          end
          order.each do |o|
            taobao_order = trade.taobao_orders.build(o)
          end

          trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取订单')
          trade.set_has_onsite_service if account.settings.enable_module_onsite_service == 1
          if users
            trade.set_operator(users,total_percent)
          end
          trade.save
          forecast_seller_id = trade.matched_seller_with_default(nil).id rescue forecast_seller_id = nil
          if forecast_seller_id.present?
            trade.update_attribute(:forecast_seller_id, forecast_seller_id)
            if trade.status == "WAIT_SELLER_SEND_GOODS" && trade.seller_id.blank?
              trade.update_stock_forecast
            end
          end

          $redis.sadd('TaobaoTradeTids',trade['tid'])
          TradeTaobaoMemoFetcher.perform_async(trade.tid)
          TradeTaobaoPromotionFetcher.perform_async(trade.tid)
          if account.settings.auto_settings['auto_dispatch']
            result = account.can_auto_dispatch_right_now
            DelayAutoDispatch.perform_in((result == true ?  account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), trade.id)
          end
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end

    def create_by_tid(tid, trade_source_id)

      trade_source = TradeSource.find_by_id(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find_by_id(account_id)

      # 给客服分配定单需要的查询
      users = account.users.where(can_assign_trade: true).where(active: true).order(:created_at) rescue nil
      if users
        total_percent = users.inject(0) { |sum, el| sum += el.trade_percent.to_i }
      end

      response = TaobaoQuery.get({
        method: 'taobao.trade.fullinfo.get', tid: tid,
        fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        }, trade_source_id
      )

      unless response['trade_fullinfo_get_response']
        Notifier.puller_errors(response, account_id).deliver
        return
      end

      trade = response['trade_fullinfo_get_response']['trade']

      return if trade.blank?

      orders = trade.delete('orders')

      trade = TaobaoTrade.new(trade)

      trade.trade_source_id = trade_source_id

      trade.account_id = account_id

      order = orders['order']

      unless order.is_a?(Array)
        order = [] << order
      end
      order.each do |o|
        taobao_order = trade.taobao_orders.build(o)
      end

      trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取订单')
      trade.set_has_onsite_service
      if users
        trade.set_operator(users,total_percent)
      end
      trade.save

      TradeTaobaoMemoFetcher.perform_async(trade.tid)
      TradeTaobaoPromotionFetcher.perform_async(trade.tid)
      if account.settings.auto_settings['auto_dispatch']
        result = account.can_auto_dispatch_right_now
        DelayAutoDispatch.perform_in((result == true ?  account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), trade.id)
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

      trade_source = TradeSource.find_by_id(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find_by_id(account_id)

      if start_time.blank?
        if TaobaoTrade.where(account_id: account_id).count > 1
          latest_created_order = TaobaoTrade.only(:modified, :account_id).where(account_id: account_id).order_by(:modified.desc).limit(1).first
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
        total_pages = nil
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

          unless response['trades_sold_increment_get_response']
            Notifier.puller_errors(response, account_id).deliver
            break
          end

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
          #同步本地顾客管理下面的"副本订单"
          CustomerFetch.perform_async(account_id)
        end
      end
    end

    def update_by_tid(trade)

      trade_source_id = trade.trade_source_id
      tid = trade.tid
      account = trade.fetch_account
      account_id = account.id

      response = TaobaoQuery.get({
        method: 'taobao.trade.fullinfo.get',
        fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee',
        tid: tid}, trade_source_id
      )

      unless response['trade_fullinfo_get_response']
        Notifier.puller_errors(response, account_id).deliver
      end

      trade = response['trade_fullinfo_get_response']['trade']
      update_trade(trade, account, trade_source_id)
    end

    def updatable?(local_trade, remote_status)
      !local_trade.splitted || (local_trade.splitted && remote_status != local_trade.status && remote_status != "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.blank?)
    end

    def update_trade(trade, account, trade_source_id)
      TaobaoTrade.where(tid: trade['tid']).each do |local_trade|
        next unless updatable?(local_trade, trade['status'])
        trade_old_status = local_trade.status
        orders = trade.delete('orders')
        trade['trade_source_id'] = trade_source_id
        local_trade.update_attributes(trade)
        if local_trade.changed?
          local_trade.operation_logs.build(operated_at: Time.now, operation: "从淘宝更新订单,更新#{local_trade.changed.try(:join, ',')}")
          local_trade.news = 1
        end
        local_trade.set_has_onsite_service
        local_trade.set_alipay_data
        local_trade.save

        if trade_old_status != "WAIT_SELLER_SEND_GOODS" && local_trade.status == "WAIT_SELLER_SEND_GOODS" && local_trade.seller_id.blank?
          local_trade.update_stock_forecast
        end
        if account.settings.auto_settings['auto_dispatch']
          result = account.can_auto_dispatch_right_now
          DelayAutoDispatch.perform_in((result == true ? account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), local_trade.id)
        end
        TradeTaobaoMemoFetcher.perform_async(local_trade.tid)
      end
    end

    def update_by_created(start_time = nil, end_time = nil, trade_source_id)
      total_pages = nil
      page_no = 1

      trade_source = TradeSource.find_by_id(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find_by_id(trade_source.account_id)

      if start_time.blank?
        latest_created_order = TaobaoTrade.only(:created, :account_id).where(account_id: account_id).order_by(:created.desc).limit(1).first
        start_time = latest_created_order.created - 1.hour
      end

      if end_time.blank?
        end_time = Time.now
      end

      begin
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, end_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 40}, trade_source_id
          )

        unless response['trades_sold_get_response']
          break
        end

        total_results = response['trades_sold_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 40
        next if total_results < 1
        trades = response['trades_sold_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end
        next if trades.blank?

        trades.each do |trade|

          next unless TaobaoTrade.where(tid: trade['tid']).exists?

          TaobaoTrade.where(tid: trade['tid']).each do |local_trade|
            next unless updatable?(local_trade, trade['status'])
            orders = trade.delete('orders')
            trade['trade_source_id'] = trade_source_id
            local_trade.update_attributes(trade)
            local_trade.operation_logs.build(operated_at: Time.now, operation: "订单状态核查,更新#{local_trade.changed.try(:join, ',')}") if local_trade.changed?
            local_trade.set_has_onsite_service
            local_trade.save
            if account.settings.auto_settings['auto_dispatch']
              result = account.can_auto_dispatch_right_now
              DelayAutoDispatch.perform_in((result == true ? account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), local_trade.id)
            end
            TradeTaobaoMemoFetcher.perform_async(local_trade.tid)
          end
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end
  end
end
