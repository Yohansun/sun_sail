# -*- encoding : utf-8 -*-
class YihaodianTradePuller
  class << self
    def create(start_time = nil, end_time = nil, account_id)
      total_pages = nil
      page_no = 1

      account = Account.find(account_id)
      trade_source = account.yihaodian_source
      trade_source_id = trade_source.id

      # 给客服分配订单需要的查询
      users = account.users.where(can_assign_trade: true, active: true).order(:created_at) rescue nil
      if users
        total_percent = users.inject(0) { |sum, el| sum += el.trade_percent.to_i }
      end

      #一号店开始时间、结束时间范围不能超过15天
      if start_time.blank?
        latest_created_order = YihaodianTrade.only("created").order_by(:created.desc).limit(1).first
        if (latest_created_order && latest_created_order.created > 14.days.ago)
          start_time = latest_created_order.created - 1.hour
        else
          start_time = 14.days.ago
        end
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.yihaodian_trade_created_boundary.to_time(:local) rescue nil
      if created_boundary.respond_to?(:to_time)
        if created_boundary > start_time
          start_time = created_boundary
        end
      end

      if end_time.blank?
        end_time = Time.now
      end

      order_states = 'ORDER_WAIT_PAY,ORDER_PAYED,ORDER_WAIT_SEND,ORDER_ON_SENDING,ORDER_RECEIVED,ORDER_FINISH,ORDER_GRT,ORDER_CANCEL'
      query_conditions = account.yihaodian_query_conditions
      begin
        #获取订单编号列表
        response = YihaodianQuery.post({method: 'yhd.orders.get',
          orderStatusList: order_states,
          startTime: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          endTime: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          curPage: page_no,
          pageRows: 10}, query_conditions).underscore_key


        unless response['response']['error_count'] == 0
          Notifier.puller_errors(response, account_id).deliver
          return
        end

        total_results = response['response']['total_count']
        total_pages = total_results / 10
        next if total_results < 1

        #通过订单编号列表获取订单详细信息
        trade_codes = response['response']['order_list']['order'].collect{|o| o['order_code']}.join(",")
        detail_response = YihaodianQuery.post({method: 'yhd.orders.detail.get',
          orderCodeList: trade_codes,
          }, query_conditions).underscore_key
        trades = detail_response['response']['order_info_list']['order_info']
        next if trades.blank?

        #抓取YihaodianTrade基本信息
        trades.each do |t|
          orders = t['order_item_list']['order_item']
          trade_params = t["order_detail"]
          unless ($redis.sismember('YihaodianTradeTids', trade_params['order_code']) || YihaodianTrade.where(tid: trade_params['order_code']).exists?)
            trade = YihaodianTrade.new(trade_params)

            orders.each do |order|
              order['order_item_id'] = order.delete('id')
              order = trade.yihaodian_orders.build(order)
              order.oid = trade.tid
            end

            trade.trade_source_id = trade_source_id
            trade.account_id = account_id
            trade.seller_nick = trade_source.name
            trade.operation_logs.build(operated_at: Time.now, operation: '从一号店抓取订单')

            if users
              trade.set_operator
            end

            trade.save!

            $redis.sadd('YihaodianTradeTids',trade_params['order_code'])
            TradeYihaodianMemoFetcher.perform_async(trade.tid)

          else
            trade = YihaodianTrade.where(tid: trade_params['order_code']).first
            next unless trade
            trade.update_attributes(trade_params)
          end
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
      #同步本地顾客管理下面的"副本订单" : 注意 一号店没有顾客相关信息无法做顾客管理
      #CustomerFetch.perform_async(account_id,'YihaodianTrade')
      #抓取订单退货信息
      YihaodianRefundOrderMarker.perform_async(account_id)
    end

  end
end