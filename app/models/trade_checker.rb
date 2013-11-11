# -*- encoding : utf-8 -*-
# == 系统订单异常信息
# * 淘宝与本地状态不同步订单 & 漏掉订单
# * 本地发货状态异常订单
# * 标记有留言但是留言还没有抓取到的订单
# * 标杆已反馈信息但系统没更新的订单
class TradeChecker
  class DateTypeError < Exception; end
  class TaobaoBase < TaobaoTrade
    scope :bad_deliver_status_of_orders, ->(account_id,start_time,end_time) do
      time_range_with_account(account_id,start_time,end_time).only(:tid, :status, :track_goods_status).
      where({"$or" => [{"status" => "WAIT_SELLER_SEND_GOODS", "delivered_at" => {"$ne" => nil}, "_type" => "TaobaoTrade"}, {"_type" => "TaobaoTrade", "unusual_states" => {"$elemMatch" => {"reason" => /发货异常/, "repaired_at" => nil}}}]})
    end

    scope :hidden_orders,     ->(account_id,start_time,end_time) do
      time_range_with_account(account_id,start_time,end_time).only(:tid, :has_buyer_message, :buyer_message).
      where(has_buyer_message: true, buyer_message: nil,:_type => "TaobaoTrade")
    end
  end

  attr_writer :lost_orders,:wrong_orders
  attr_reader :account_key,:account,:trade_source,:start_time,:end_time,:options,:lost_orders,:wrong_orders,:bad_deliver_status_of_orders,:hidden_orders,:biaogan_diff,:exceptions

  # === Example
  #    TradeChecker.new(:brands,time: Time.now, ago: -1.day).invoke                                 # 一天后到现在
  #    TradeChecker.new(:brands,time: Time.now, ago: 1.day).invoke                                  # 一天前到现在
  #    TradeChecker.new(:brands,start_time: Time.now.yesterday, end_time: Time.now).invoke          # 昨天凌晨1点到现在
  # === Options
  # [:start_time]
  #   查询的开始时间
  # [:end_time]
  #   查询的结束时间
  # [:time]
  #   查询的计算时间
  # [:ago]
  #   *  2 2天前
  #   * -2 2天后
  # === SendMail Options
  #    TradeChecker.new(:brands,time: Time.now, ago: -1,:to => 'zhoubin@networking.io',:from => "exception@networking.io").invoke
  # [:tag]
  #   summary of subject
  #   Default is '异常核查报告'
  # [:to]
  #   same as send mail option +:to+
  # [:from]
  #   same as send mail option +:from+
  # [:bcc]
  #   same as send mail option +:bcc+
  # [:cc]
  #   same as send mail option +:cc+
  def initialize(*args)
    @options = args.extract_options!
    @options.symbolize_keys!
    @account_key = args.shift
    raise ArgumentError,"account_key can't be blank!" if  account_key.blank?
    @options[:time] ||= Time.now
    @account = Account.find_by_key(account_key) or raise("没有找到account key为#{account_key}的账户")
    @trade_source = @account.trade_sources.where(trade_type: "Taobao").first
    # 抓取昨天 的订单, 检查本地状态和淘宝状态是否匹配
    @options[:ago] ||= 1.day
    @start_time , @end_time = process_time(@options[:time],@options[:ago])
    @start_time = @options[:start_time] if @options[:start_time]
    @end_time   = @options[:end_time] if @options[:end_time]
    raise DateTypeError,"Time type is incorrect" if [@start_time,@end_time].any? {|x| !(x.is_a?(Time) || x.is_a?(DateTime))}
    @lost_orders,@wrong_orders,@bad_deliver_status_of_orders,@hidden_orders,@biaogan_diff,@exceptions =  Array.new(6) { [] }
    @mail = options.slice(:to,:from,:bcc,:cc).reject{|k,v| v.blank?}
  end

  def invoke
    DailyOrdersNotifier.check_status_result(taobao_trade_status,@mail).deliver!
  end

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
      response = catch_exception("标杆仓库API异常(:shipment_info_query_by_date)") { Bml.shipment_info_query_by_date(account,date) }
      response.blank? && next
      hash = catch_exception("标杆仓库 / [#{start_date}] 没有记录") { Hash.from_xml(response)["outputBacks"]["outputBack"] }
      hash.blank? && next
      hash.each { |stock| abnormal_collections_with_stock(stock["orderNo"],stock["shipNo"]) }
    end
  end

  private
  def abnormal_collections_with_taobao(taobao_trade)
    tid = taobao_trade["tid"].to_s
    taobao_trades = Trade.where(tid: tid).only(:status,:trade_source_id,:tid)
    if local_trade = taobao_trades.first
      # ERROR: 淘宝与本地状态不同步订单
      if local_trade.status != taobao_trade['status']
        @wrong_orders << tid if (local_trade.splitted && taobao_trades.distinct(:status).length == 1) || !local_trade.splitted
        TaobaoTradePuller.update_by_tid(local_trade)
      end
    else
      # ERROR: 漏掉订单,考虑合并删除的订单
      @lost_orders << tid unless Trade.unscoped.where(tid: tid).exists?
    end
  end

  def abnormal_collections_with_stock(tid,logistic_waybill)
    trade = catch_exception("标杆仓库 tid为#{tid} 在本地没有找到此订单"){ Trade.find_by(:tid => tid) }
    return if trade.blank?
    @biaogan_diff << tid if trade.logistic_waybill.blank?
  end

  def fetch_taobao_trades(page_no)
    TaobaoQuery.get({
      method: 'taobao.trades.sold.get',
      type: 'fixed,auction,guarantee_trade,step,independent_simple_trade,independent_shop_trade,auto_delivery,ec,cod,game_equipment,shopex_trade,netcn_trade,external_trade,instant_trade,b2c_cod,hotel_trade,super_market_trade,super_market_cod_trade,taohua,waimai,nopaid,eticket,tmall_i18n',
      fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
      start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
      page_no: page_no, page_size: 80}, trade_source.id
      )
  end

  def process_time(time,ago)
    time = time.to_time(:local) if !time.is_a?(Time)
    time_ago       = time.ago(ago)
    [time, time_ago].sort.tap do |times|
      times[0] = times[0]
      times[1] = times[1]
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