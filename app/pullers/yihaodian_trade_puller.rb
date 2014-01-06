# -*- encoding : utf-8 -*-
class YihaodianTradePuller
  ORDER_STATS = 'ORDER_WAIT_PAY,ORDER_PAYED,ORDER_WAIT_SEND,ORDER_ON_SENDING,ORDER_RECEIVED,ORDER_FINISH,ORDER_GRT,ORDER_CANCEL'
  PAGE_ROWS = 50 # Don't change number!!!
  class << self
    def create(start_time = nil, end_time = nil, account_id)
      Account.find(account_id).yihaodian_source_ids.each do |trade_source_id|
        create_with_source(trade_source_id,start_time,end_time)
      end
    end

    def create_with_source(trade_source_id,start_time=nil,end_time=Time.now)
      total_pages = nil
      page_no = 1

      trade_source = TradeSource.find(trade_source_id)
      account = trade_source.account

      # 给客服分配订单需要的查询
      users = account.users.where(can_assign_trade: true, active: true).exists?

      #一号店开始时间、结束时间范围不能超过15天
      if start_time.blank?
        latest = YihaodianTrade.only("created").order_by(:created.desc).limit(1).first
        start_time = (latest && latest.created > 14.days.ago) ? (latest.created - 1.hour) : 14.days.ago
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.yihaodian_trade_created_boundary.to_time(:local) rescue nil
      start_time = created_boundary if created_boundary.respond_to?(:to_time) && created_boundary > start_time

      options = {start_time: start_time,end_time: end_time,query_conditions: trade_source.yihaodian_query_conditions}
      each_page(options) do |response|
        response['response']['order_info_list']['order_info'].each do |t|
          t["order_detail"].merge!({trade_source_id: trade_source_id,account_id: account.id,seller_nick: trade_source.name})
          trade = create_or_update(t)
          trade.set_operator if users
        end
      end

      #同步本地顾客管理下面的"副本订单" : 注意 一号店没有顾客相关信息无法做顾客管理
      #CustomerFetch.perform_async(trade_source.id,'YihaodianTrade')
      #抓取订单退货信息
      YihaodianRefundOrderMarker.perform_async(trade_source_id)
    end

    # 遍历给定的时间区间内所有的页
    # requires keys:
    #   :start_time:        # Time.now - 1.month
    #   :end_time:          # Time.now
    #   :query_conditions:  # trade_source.yihaodian_query_conditions
    #
    #   YihaodianTradePuller.each_page(options) do |response|
    #     response['blabla']['trade_lists'].each do |trade|
    #       # dosometing
    #     end
    #   end
    def each_page(options={},&block)
      options[:page_no]    ||= 1
      options[:total_page] ||= 0
      fetch_trades(options) do |response|
        tids = response["response"]["order_list"]["order"].collect {|order| order["order_code"]}
        fetch_details(tids,options) { |response| yield response }
        options[:total_page] ||= (response["response"]["total_count"].to_i / PAGE_ROWS.to_f).ceil
        options[:page_no] += 1
      end
      return if options[:total_page] == 0
      if options[:page_no] <= options[:total_page]
        each_page(options,&block)
      else
        options.delete(:page_no)
      end
    end

    # 批量抓取一号店订单列表
    def fetch_trades(options,&block)
      start_time = options[:start_time]
      if ((options[:end_time] - start_time) / 1.day) > 15
        start_time = options[:end_time] - 15.days
        Rails.logger.warn "[#{Time.now}] #{name}.#{__method__} 一号店只允许查询时间间隔为15天的订单数据, 系统自动处理开始时间为 结束时间前15天的一号店订单"
      end
      data = {parameters: {method: "yhd.orders.get",orderStatusList: ORDER_STATS,startTime: start_time.strftime("%Y-%m-%d %H:%M:%S"),endTime: options[:end_time].strftime("%Y-%m-%d %H:%M:%S"),pageRows: 50,curPage: options[:page_no]}}
      response = YihaodianQuery.post(data[:parameters],options[:query_conditions]).underscore_key
      cache_exception(message: options[:error_message] || "一号店订单抓取异常(列表)",data: data.merge(response: response)) { yield response }
    end

    # 批量抓取一号店订单详细列表(根据订单编号)
    def fetch_details(tids,options={},&block)
      data = {parameters: { method: "yhd.orders.detail.get",orderCodeList: tids.join(',') }}
      response = YihaodianQuery.post(data[:parameters],options[:query_conditions]).underscore_key
      cache_exception(message: options[:error_message] || "一号店订单抓取异常(详细列表)",data: data.merge(response: response)) { yield response }
    end

    def exists_trade?(tid)
      $redis.sismember('YihaodianTradeTids', tid) || YihaodianTrade.where(tid: tid).exists?
    end

    def create_or_update(response)
      attrs = parse_response(response)
      action = 'nil'
      tid = attrs['order_code']
      if exists_trade?(tid)
        action = "Update"
        trade = YihaodianTrade.find_by(tid: tid)
        trade.update_attributes(attrs)
      else
        action = "Create"
        attrs[:operation_logs] = [{operated_at: Time.now, operation: '从一号店抓取订单'}]
        trade = YihaodianTrade.create!(attrs)
        $redis.sadd('YihaodianTradeTids',tid)
        TradeYihaodianMemoFetcher.perform_async(tid)
      end
      Rails.logger.info "[#{Time.now}] #{action} by #{self.name}##{__method__} as \n  Parameters: #{attrs.inspect} \n Changes: #{trade.previous_changes.inspect if action == 'Update'}"
      trade
    end

    def update_by_tid(tid,trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      data = {parameters: {method: 'yhd.order.detail.get',orderCode: tid}}
      response = YihaodianQuery.post(data[:parameters], trade_source.yihaodian_query_conditions).underscore_key
      trade_attrs = cache_exception(message: "一号店订单抓取异常(#{trade_source.name})",data: data.merge(response: response)) {
        create_or_update(response["response"]["order_info"])
      }
    end

    # 处理response中 订单的结构,  当然,参数就是订单结构的那块. 处理成系统一号店订单的数据结构
    def parse_response(trade_struct)
      trade_attrs = trade_struct["order_detail"]
      yihaodian_orders = trade_struct["order_item_list"]["order_item"].tap {|orders|
        orders.each {|order|
          order["order_item_id"] = order.delete("id")
          order["oid"] = trade_attrs["order_code"]
        }
      }
      trade_attrs.merge({yihaodian_orders: yihaodian_orders})
    end
  end
end