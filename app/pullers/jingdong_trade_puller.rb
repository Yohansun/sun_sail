# -*- encoding : utf-8 -*-
class JingdongTradePuller
  PAGE_SIZE = 100
  ORDER_STATE = 'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT,WAIT_GOODS_RECEIVE_CONFIRM,FINISHED_L'
  FIELDS = 'order_id,vender_id,pay_type,order_total_price,order_payment,order_seller_price,freight_price,seller_discount,order_state,order_state_remark,delivery_type,invoice_info,order_remark,order_start_time,order_end_time,consignee_info,item_info_list,coupon_detail_list,return_order,vender_remark,pin,balance_used,modified,payment_confirm_time,logistics_id,waybill,vat_invoice_info'
  class << self
    def create(start_time = nil, end_time = nil, account_id)
      Account.find(account_id).jingdong_source_ids.each do |trade_source_id|
        create_with_source(trade_source_id,start_time,end_time)
      end
    end

    def create_with_source(trade_source_id,start_time=nil,end_time=Time.now)
      trade_source = TradeSource.where(trade_type: "Jingdong",id: trade_source_id).first
      account = Account.find(trade_source.account_id)

      users = users?(account)

      if start_time.blank?
        latest_created_order = JingdongTrade.where(trade_source_id: trade_source_id).only("created").order_by(:created.desc).limit(1).first
        start_time = latest_created_order ? (latest_created_order.created - 1.hour) : 1.month.ago
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.jingdong_trade_created_boundary.to_time(:local) rescue nil
      start_time = created_boundary if created_boundary.respond_to?(:to_time) && created_boundary > start_time

      options = {start_time: start_time,end_time: end_time,query_conditions: trade_source.jingdong_query_conditions}
      each_page(options) do |response|
        trades = response['order_search_response']['order_search']['order_info_list']
        #抓取JingdongTrade基本信息
        trades.each do |t|
          attrs = t.merge!({trade_source_id: trade_source_id,account_id: account.id,seller_nick: trade_source.name,operation_logs: [{operated_at: Time.now, operation: '从京东抓取订单'}]})
          trade = create_or_update(attrs)
          trade.set_operator if users
        end
      end

      #同步本地顾客管理下面的"副本订单"
      CustomerFetch.perform_async(trade_source_id,'JingdongTrade')
      #抓取订单退货信息
      JingdongRefundOrderMarker.perform_async(trade_source_id)
    end

    # 给客服分配订单需要的查询
    def users?(account)
      account.users.where(can_assign_trade: true, active: true).exists?
    end

    # 处理response中 订单的结构,  当然,参数就是订单结构的那块. 处理成系统中京东订单的数据结构
    def parse_response(trade_struct)
      trade_struct.tap do |struct|
        struct.delete('payment_confirm_time') if struct['payment_confirm_time'] == '0001-01-01 00:00:00'
        struct.delete('order_end_time')       if struct['order_end_time']       == '0001-01-01 00:00:00'        || struct['order_end_time'] == '1970-01-01 00:00:00'
        struct["consign_time"]    = Time.now  if struct['order_state']          == "WAIT_GOODS_RECEIVE_CONFIRM" || struct['order_state']    == "FINISHED_L"
        struct["coupon_details"]  = struct.delete("coupon_detail_list")
        struct["jingdong_orders"] = struct.delete('item_info_list').tap {|orders| orders && orders.each {|order| order["oid"] = struct["order_id"]}}
      end.merge!(trade_struct.delete("consignee_info") || {}).reject {|k,v| v.nil?}
    end

    # 遍历给定的时间区间内所有的页
    # requires keys:
    #   :start_time:        # Time.now - 1.month
    #   :end_time:          # Time.now
    #   :query_conditions:  # trade_source.jingdong_query_conditions
    #
    #   JingdongTradePuller.each_page(options) do |response|
    #     response['blabla']['trade_lists'].each do |trade|
    #       # dosometing
    #     end
    #   end
    def each_page(options={},&block)
      options[:page_no]     ||= 1
      options[:total_pages] ||= 0
      fetch_trades(options) do |response|
        options[:total_results] ||= response['order_search_response']['order_search']['order_total']
        options[:total_pages]   ||= (options[:total_results] / PAGE_SIZE.to_f).ceil
        yield response
        options[:page_no] += 1
      end
      return if options[:total_results] == 0
      if options[:page_no] <= options[:total_pages]
        each_page(options,&block)
      else
        options.delete(:page_no)
      end
    end

    def fetch_trades(options={},&block)
      data = {
        parameters: {
          method: '360buy.order.search',order_state: ORDER_STATE,
          start_date: options[:start_time].strftime("%Y-%m-%d %H:%M:%S"),
          end_date: options[:end_time].strftime("%Y-%m-%d %H:%M:%S"),
          optional_fields: FIELDS,page_size: PAGE_SIZE
          }
        }
      response = JingdongQuery.get(data[:parameters].merge!(page: options[:page_no]).dup, options[:query_conditions])
      cache_exception(message: options[:error_message] || "京东订单抓取异常",data: data.merge(response: response)) { yield response}
    end

    def create_or_update(attrs)
      attrs = parse_response(attrs)
      action = nil

      if exists_trade?(attrs)
        action = "Updata"
        trade = JingdongTrade.find_by(tid: attrs['order_id'])
        trade.update_attributes!(attrs)
      else
        action = "Create"
        trade = JingdongTrade.create!(attrs)
        $redis.sadd('JingdongTradeTids',attrs['order_id'])
        TradeJingdongMemoFetcher.perform_async(trade.tid)
      end
      Rails.logger.info "[#{Time.now}] #{action} by #{self.name}##{__method__} as \n  Parameters: #{attrs.inspect} \n Changes: #{trade.previous_changes.inspect  if action == 'Update'}"
      trade
    end

    def exists_trade?(attrs)
      $redis.sismember('JingdongTradeTids', attrs['order_id']) || JingdongTrade.where(tid: attrs['order_id']).exists? || attrs['order_state'] == "TRADE_CANCELED"
    end

    def update_by_tid(tid,trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      data = {parameters: {method: '360buy.order.get',order_id: tid,optional_fields: FIELDS}}
      response = JingdongQuery.get(data[:parameters], trade_source.jingdong_query_conditions)
      cache_exception(message: "京东订单抓取异常(#{trade_source.name})",data: data.merge(response: response)) {
        trades = response['order_get_response']['order']['orderInfo']
        attrs = trade.merge!({trade_source_id: trade_source_id,account_id: account.id,seller_nick: trade_source.name})
        create_or_update(attrs)
      }
    end
  end
end
