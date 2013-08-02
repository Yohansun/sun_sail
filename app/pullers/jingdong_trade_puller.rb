# -*- encoding : utf-8 -*-
class JingdongTradePuller
  class << self
    def create(start_time = nil, end_time = nil, account_id)
      total_pages = nil
      page_no = 1

      account = Account.find(account_id)
      trade_source = account.jingdong_source

      # 给客服分配订单需要的查询
      users = account.users.where(can_assign_trade: true, active: true).order(:created_at) rescue nil
      if users
        total_percent = users.inject(0) { |sum, el| sum += el.trade_percent.to_i }
      end

      if start_time.blank?
        latest_created_order = JingdongTrade.only("created").order_by(:created.desc).limit(1).first
        if latest_created_order
          start_time = latest_created_order.created - 1.hour
        else
          start_time = 1.month.ago
        end
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.jingdong_trade_created_boundary.to_time(:local) rescue nil
      if created_boundary.respond_to?(:to_time)
        if created_boundary > start_time
          start_time = created_boundary
        end
      end

      if end_time.blank?
        end_time = Time.now
      end

      order_states = 'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT,WAIT_GOODS_RECEIVE_CONFIRM,FINISHED_L,TRADE_CANCELED'
      begin
        response = JingdongQuery.get({method: '360buy.order.search',
          order_state: order_states,
          start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page: page_no,
          page_size: 10}, account_id)

        unless response['order_search_response']
          Notifier.puller_errors(response, account_id).deliver
          return
        end

        total_results = response['order_search_response']['order_search']['order_total']
        total_pages = total_results / 10
        next if total_results < 1

        # default_seller_id = account.settings.default_seller_id

        trades = response['order_search_response']['order_search']['order_info_list']
        next if trades.blank?

        trades.each do |t|
          orders = t.delete('item_info_list')
          consignee_info = t.delete("consignee_info")
          t.update(consignee_info)
          unless ($redis.sismember('JingdongTradeTids', t['order_id']) || JingdongTrade.where(tid: t['order_id']).exists?)
            trade = JingdongTrade.new(t)
            orders.each do |order|
              order = trade.jingdong_orders.build(order)
            end

            trade.trade_source_id = trade_source_id
            trade.account_id = account_id
            trade.operation_logs.build(operated_at: Time.now, operation: '从京东抓取订单')

            if users
              trade.set_operator(users,total_percent)
            end

            trade.save

            $redis.sadd('JingdongTradeTids',t['order_id'])

            #PENDING 抓取memo,抓取coupon_details,自动化功能
            # auto dispatch

            # if trade.order_remark.blank? && (trade.order_state == "WAIT_SELLER_DELIVERY" || trade.order_state == "WAIT_SELLER_STOCK_OUT")
            #   trade.update_attributes(seller_id: default_seller_id, dispatched_at: Time.now)
            # end
          else
            #trade.update_attributes(order_state: t['order_state'], order_state_remark: t['order_state_remark'], order_end_time: t['order_end_time'])
            trade = JingdongTrade.where(tid: t['order_id']).first
            return unless trade

            trade.update_attributes(t)
          end

        end
        page_no += 1
      end until(page_no > total_pages || total_pages == 0)

      #同步本地顾客管理下面的"副本订单"
      CustomerFetch.perform_async(account_id)
    end

  end
end
