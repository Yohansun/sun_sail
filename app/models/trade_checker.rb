# -*- encoding : utf-8 -*-
require "savon"
class TradeChecker
  class TaobaoBase < TaobaoTrade
    scope :bad_deliver_status_of_orders, ->(account_id,start_time,end_time) do
      time_range_with_account(account_id,start_time,end_time).only(:tid, :status, :track_goods_status).
      where(:status => "WAIT_SELLER_SEND_GOODS", :delivered_at.ne => nil,:_type => "TaobaoTrade")
    end

    scope :hidden_orders,     ->(account_id,start_time,end_time) do
      time_range_with_account(account_id,start_time,end_time).only(:tid, :has_buyer_message, :buyer_message).
      where(has_buyer_message: true, buyer_message: nil,:_type => "TaobaoTrade")
    end
  end

  attr_writer :lost_orders,:wrong_orders
  attr_reader :account_key,:account,:trade_source,:start_time,:end_time,:options,:lost_orders,:wrong_orders,:bad_deliver_status_of_orders,:hidden_orders,:biaogan_diff,:exceptions

  # TradeChecker.new(account_key,time: Time.now, ago: -1).invoke
  # - arguments for options
  #   - *time* Time.now
  #     => start_time = end_time = time
  #   - *ago*  3.days
  #     => start_time,end_time = [time,time.ago(number)].sort   #number can be -number or +number
  def initialize(*args)
    @options = args.extract_options!
    @options.symbolize_keys!
    @account_key = args.shift
    raise "account_key can't be blank!" if  account_key.blank?
    @options[:time] ||= Date.yesterday
    @account = Account.find_by_key(account_key) or raise("没有找到account key为#{account_key}的账户")
    @trade_source_id = @account.trade_source.id
    @trade_source = TradeSource.find(@trade_source_id)
    # 抓取昨天 的订单, 检查本地状态和淘宝状态是否匹配
    @options[:ago] ||= 0
    @start_time , @end_time = process_time(@options[:time],@options[:ago].days)

    @lost_orders        = []
    @wrong_orders       = []
    @bad_deliver_status_of_orders  = []
    @hidden_orders      = []
    @biaogan_diff       = []
    @exceptions         = []
  end

  def invoke
    DailyOrdersNotifier.check_status_result(taobao_trade_status).deliver!
  end

  # 订单异常报告
  #
  def taobao_trade_status
    # 淘宝与本地状态不同步订单 & 漏掉订单
    checking_trades_with_taobao
    # 本地发货状态异常订单
    @bad_deliver_status_of_orders = TaobaoBase.bad_deliver_status_of_orders(account.id,start_time,end_time).distinct(:tid)
    # 标记有留言但是留言还没有抓取到的订单
    @hidden_orders     = TaobaoBase.hidden_orders(account.id,start_time,end_time).distinct(:tid)
    # 标杆已反馈信息但系统没更新的订单：
    checking_trades_with_biaogan
    TaobaoTrade.rescue_buyer_message(hidden_orders)
    return self
  end

  def checking_trades_with_taobao
    has_next = true
    page_no = 1
    while has_next
      response = fetch_taobao_trades(page_no)
      page_no += 1
      has_next = catch_exception("淘宝API调用异常 #{response["error_response"]}") { response['trades_sold_get_response']['has_next'] }
      break if has_next == false

      trades = Array.wrap(response['trades_sold_get_response']['trades']['trade']) rescue []
      next if trades.blank?
      trades.each {|trade| abnormal_collections_with_taobao(trade) }
    end
  end

  def checking_trades_with_biaogan
    #标杆仓库只能查询近一个星期之内的数据
    start_date,end_date = start_time.to_date,end_time.to_date
    if start_time < Time.now.beginning_of_day.ago(7.days)
      @exceptions << ExceptionNotifier.new("标杆仓库只能查询最近一个星期内的数据")
      return
    end

    (start_date..end_date).each do |date|
      response = catch_exception("标杆仓库API异常(:shipment_info_query_by_date)") { Bml.shipment_info_query_by_date(date) }
      response.blank? && next
      hash = catch_exception("标杆仓库 / [#{start_date}] 没有记录") { Hash.from_xml(response)["outputBacks"]["outputBack"] }
      hash.blank? && next
      hash.each { |stock| abnormal_collections_with_stock(stock["orderNo"],stock["shipNo"]) }
    end
  end

  private
  def abnormal_collections_with_taobao(taobao_trade)
    tid = taobao_trade["tid"].to_s
    taobao_trades = TaobaoTrade.where(tid: tid).only(:status)
    if local_trade = taobao_trades.first
      # ERROR: 淘宝与本地状态不同步订单
      if local_trade.status != taobao_trade['status']
        @wrong_orders << tid if (local_trade.splitted && taobao_trades.distinct(:status).length == 1) || !local_trade.splitted
      end
    else
      # ERROR: 漏掉订单
      @lost_orders << tid
    end
  end

  def abnormal_collections_with_stock(tid,logistic_waybill)
    trade = catch_exception("标杆仓库 tid为#{tid} 在本地没有找到此订单"){ Trade.unscoped.find_by(:tid => tid) }
    return if trade.blank?
    @biaogan_diff << tid if trade.logistic_waybill != logistic_waybill
  end

  def fetch_taobao_trades(page_no)
    TaobaoQuery.get({
      method: 'taobao.trades.sold.get',
      fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
      start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
      page_no: page_no, page_size: 80}, trade_source.id
      )
  end

  def process_time(time,ago)
    time = time.to_time(:local) if !time.is_a?(Time)
    time_ago       = time.ago(ago)
    [time, time_ago].sort.tap do |times|
      times[0] = times[0].beginning_of_day
      times[1] = times[1].end_of_day
      times[1] = Time.now if times[1] > Time.now
    end
  end

  def catch_exception(message,&block)
    yield
  rescue Exception => e
    @exceptions << ExceptionNotifier.new(message,e.message)
    return false
  end
  class ExceptionNotifier
    attr_reader :text,:exception
    def initialize(text,exception="")
      @text = text
      @exception = exception
    end
  end
end