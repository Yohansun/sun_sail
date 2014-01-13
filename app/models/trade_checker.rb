# -*- encoding : utf-8 -*-
# == 系统订单异常信息
# * 淘宝与本地状态不同步订单 & 漏掉订单
# * 本地发货状态异常订单
# * 标记有留言但是留言还没有抓取到的订单
# * 标杆已反馈信息但系统没更新的订单
class TradeChecker
  class DateTypeError < Exception; end
  class TaobaoBase < TaobaoTrade
    scope :incomplete_data,     ->(account_id,start_time,end_time) do
      time_range_with_account(account_id,start_time,end_time).only(:tid, :has_buyer_message, :buyer_message).
      where(has_buyer_message: true, buyer_message: nil,:_type => "TaobaoTrade")
    end
  end

  attr_reader :accounts
  attr_accessor :options
  # === Example
  #    TradeChecker.new(time: Time.now, ago: -1.day).invoke                                 # 一天后到现在
  #    TradeChecker.new(time: Time.now, ago: 1.day).invoke                                  # 一天前到现在
  #    TradeChecker.new(start_time: Time.now.yesterday, end_time: Time.now).invoke          # 昨天凌晨1点到现在
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
  #    TradeChecker.new(time: Time.now, ago: -1,:to => 'zhoubin@networking.io',:from => "exception@networking.io").deliver
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
    @options = default_options.merge(args.extract_options!.symbolize_keys)
    @accounts = []
    start_time , end_time = process_time(options[:time],@options[:ago])
    options[:start_time]  = start_time  if options[:start_time].nil?
    options[:end_time]    = end_time    if options[:end_time].nil?

    validate_options!
  end

  def default_options
    {time: Time.now, ago: 1.day}
  end

  def validate_options!
    raise DateTypeError,"Time type is incorrect" if [options[:start_time],options[:end_time]].any? {|x| !(x.is_a?(Time) || x.is_a?(DateTime))}
  end

  def deliver
    check
    DailyOrdersNotifier.check_status_result(self,options.slice(:to,:from,:bcc,:cc).reject{|k,v| v.blank?}).deliver!
  end

  def check
    return self if @check == true
    TradeSource.where(enabled_checker: true).joins(:account).group(:account_id).each do |source|
      @accounts << Account.new(source.account,options)
    end
    @accounts.map(&:check)
    @check ||= true
  end

  def process_time(time,ago)
    time = time.to_time(:local) if !time.is_a?(Time)
    time_ago       = time.ago(ago)
    [time, time_ago].sort.tap do |times|
      times[0] = times[0]
      times[1] = times[1]
    end
  end

  class Account
    attr_accessor :account,:options,:trade_sources
    delegate :name,to: :account
    def initialize(account,options)
      @account = account
      @options = options
      @trade_sources = []
    end

    def check
      account.trade_sources.where(enabled_checker: true).each {|source| @trade_sources << TradeSource.new(source,options)}
      @trade_sources.map(&:check)
    end

    class TradeSource
      attr_accessor :account
      # 漏抓订单
      attr_accessor :losts
      # 本地发货状态异常订单
      attr_accessor :error_status
      # 标记有留言但是留言还没有抓取到的订单
      attr_accessor :incomplete_data
      attr_accessor :biaogan_diff
      attr_accessor :warns
      attr_accessor :trade_source,:options

      delegate :name, to: :trade_source

      def initialize(trade_source,options)
        @account = trade_source.account
        @trade_source = trade_source
        @options = options
        @losts,@error_status,@incomplete_data,@biaogan_diff,@warns =  Array.new(5) { [] }
      end

      def check
        %w(taobao jingdong yihaodian).each do |ec_name|
          send(:"checking_with_#{ec_name}") if trade_source.send(:"trade_type_#{ec_name}?") # => checking_with_taobao if trade_source.trade_type_taobao?
        end

        if trade_source.trade_type_taobao?
          # 标记有留言但是留言还没有抓取到的订单
          @incomplete_data     = processing_incomplete_data_with_taobao
          TaobaoTrade.rescue_buyer_message(incomplete_data)
        end

        # 标杆已反馈信息但系统没更新的订单：
        checking_trades_with_biaogan if trade_source.account.settings.third_party_wms == "biaogan"
      end

      def processing_incomplete_data_with_taobao
        tids = TradeChecker::TaobaoBase.incomplete_data(account.id,options[:start_time],options[:end_time]).distinct(:tid)
        return tids.collect { |tid| ::TradeTaobaoMemoFetcher.perform_async(tid); tid.to_s << "(正在处理中...)" } if tids.present?
        []
      end

      def checking_with_taobao
        has_next = true
        page_no = 1
        while has_next
          fetch_taobao_trades(page_no) do |response|
            page_no += 1
            break if !(has_next = response['trades_sold_get_response']['has_next'])
            trades = response['trades_sold_get_response']['trades']['trade']
            trades.each {|trade| abnormal_collections_with_taobao(trade) }
          end
        end
      end

      # 检查一号店订单
      def checking_with_yihaodian
        opts = options.merge(error_message: "[异常邮件检查] 一号店订单抓取异常(#{trade_source.name})",query_conditions: query_conditions)
        YihaodianTradePuller.each_page(opts) do |response|
          response["response"]["order_info_list"]["order_info"].each do |struct|
            tid = struct["order_detail"]["order_code"]
            trade = YihaodianTrade.unscoped.where(tid: tid).first
            if trade
              next if trade.deleted?
              if trade.status != struct["order_detail"]["order_status"]
                YihaodianTradePuller.create_or_update(struct)
                error_status << "#{tid}(已处理)"
              end
            else
              struct["order_detail"].merge!(account_id: account.id,trade_source_id: trade_source.id,seller_nick: trade_source.name)
              YihaodianTradePuller.create_or_update(struct)
              losts << "#{tid}(已处理)"
            end
          end
        end
      end

      # 检查京东订单
      def checking_with_jingdong
        opts = options.merge(error_message: "[异常邮件检查] 京东订单抓取异常(#{trade_source.name})",query_conditions: query_conditions)
        JingdongTradePuller.each_page(opts) do |response|
          response['order_search_response']['order_search']['order_info_list'].each do |struct|
            tid = struct["order_id"]
            trade = JingdongTrade.unscoped.where(tid: tid).first
            if trade
              next if trade.deleted?
              if trade.status != struct["order_state"]
                JingdongTradePuller.create_or_update(struct)
                error_status << "#{tid}(已处理)"
              end
            else
              struct.merge!({trade_source_id: trade_source.id,account_id: account.id,seller_nick: trade_source.name,operation_logs: [{operated_at: Time.now, operation: '从京东抓取订单'}]})
              trade = JingdongTradePuller.create_or_update(struct)
              losts << "#{tid}(已处理)"
            end
          end
        end
      end

      # cache query
      def query_conditions
        @query_conditions ||= (trade_source.yihaodian_query_conditions || trade_source.jingdong_query_conditions)
      end

      def checking_trades_with_biaogan
        #标杆仓库只能查询近一个星期之内的数据
        start_date,end_date = options[:start_time].to_date,options[:end_time].to_date
        min_time = Time.now.beginning_of_day.ago(7.days)
        if options[:start_time] < min_time
          start_date = min_time.to_date
          end_date = min_time.to_date if options[:end_time] < min_time
          end_date = Time.now.to_date if options[:end_time] > Time.now
          @warns << "标杆仓库只能查询最近一个星期内的数据"
        end

        (start_date..end_date).each do |date|
          parameters = {account: account,date: date}
          response = Bml.shipment_info_query_by_date(account,date)
          cache_exception(message: "[异常邮件检查] 对接标杆仓库异常(:shipment_info_query_by_date)(#{trade_source.name})",data: {parameters: parameters,response: response}) do
            datas =  Hash.from_xml(response)["outputBacks"]["outputBack"]
            if datas.is_a?(Array)
              datas.each {|stock| abnormal_collections_with_stock(stock)}
            else
              abnormal_collections_with_stock(datas)
            end
          end
        end
      end

      private
      def abnormal_collections_with_taobao(taobao_trade)
        tid = taobao_trade["tid"].to_s
        taobao_trades = Trade.where(tid: tid).only(:status,:trade_source_id,:tid,:account_id)
        if local_trade = taobao_trades.first
          # ERROR: 淘宝与本地状态不同步订单
          if local_trade.status != taobao_trade['status']
            if (local_trade.splitted && taobao_trades.distinct(:status).length == 1) || !local_trade.splitted
              @error_status << (tid << (TaobaoTradePuller.update_by_tid(local_trade) ? "(已处理)" : "(未处理)"))
            end
          end
        else
          # ERROR: 漏掉订单,考虑合并删除的订单
          if !Trade.unscoped.where(tid: tid).exists?
            @losts << (tid << (TaobaoTradePuller.create_trade(taobao_trade,account,trade_source.id) ? "(已处理)" : "(未处理)"))
          end
        end
      end

      def abnormal_collections_with_stock(stock)
        tid,logistic_waybill = stock["orderNo"],stock["shipNo"]
        trade = Trade.unscoped.desc(:created_at).where(:tid => tid).first
        (@warns << "本地没有找到标杆仓库订单号为#{tid}") and return if trade.nil?
        if trade.logistic_waybill.blank?
          logistic = Logistic.find_by_code(stock['carrierID'])
          status_text = StockBill.where(tid: tid).desc(:created_at).first.try(:status_text)
          @biaogan_diff << ("#{tid}(%s)" % status_text.to_s)

          trade.update_attributes(
            logistic_waybill: stock['shipNo'],
            logistic_name: stock['carrierName'],
            logistic_code: stock['carrierID'],
            logistic_id: logistic.try(:id),
            service_logistic_id: trade.get_third_party_logistic_id(logistic.try(:id))
          )
        end
      end

      def fetch_taobao_trades(page_no)
        data = {
          parameters: {
            method: 'taobao.trades.sold.get',
            type: 'fixed,auction,guarantee_trade,step,independent_simple_trade,independent_shop_trade,auto_delivery,ec,cod,game_equipment,shopex_trade,netcn_trade,external_trade,instant_trade,b2c_cod,hotel_trade,super_market_trade,super_market_cod_trade,taohua,waimai,nopaid,eticket,tmall_i18n',
            fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
            start_created: options[:start_time].strftime("%Y-%m-%d %H:%M:%S"), end_created: options[:end_time].strftime("%Y-%m-%d %H:%M:%S"),
            page_no: page_no, page_size: 100,use_has_next: true
          }
        }
        response = TaobaoQuery.get(data[:parameters], trade_source.id)
        cache_exception(message: "[异常邮件检查] 淘宝订单抓取异常(#{trade_source.name})",data: data.merge(response: response)) { yield response}
        end
      end
    end
  end