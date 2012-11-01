# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  layout false, :only => :print_bill
  #layout 'application', :except => [:print_bill]
  before_filter :authenticate_user!
  respond_to :json, :xls
  include Dulux::Splitter
  include TaobaoProductsLockable

  def index
    @trades = Trade
    seller = current_user.seller
    logistic = current_user.logistic

    paid_not_deliver_array = ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT","WAIT_SELLER_SEND_GOODS_ACOUNTED"]
    paid_and_delivered_array = ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED"]
    closed_array = ["TRADE_CLOSED","TRADE_CANCELED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"]

    if current_user.has_role?(:seller)
      if seller
        @trades = Trade.where(seller_id: seller.id)
      else
        render json: []
        return
      end
    elsif current_user.has_role?(:interface)
      if seller
        @trades = Trade.where(:seller_id.in => seller.child_ids)
      else
        render json: []
        return
      end
    end

    if current_user.has_role?(:logistic)
      if logistic
        @trades = Trade.where(logistic_id: logistic.id)
      else
        render json: []
        return
      end
    end

    ###筛选开始####
    ## 导航栏
    if params[:trade_type]
      type = params[:trade_type]
      case type
      when 'taobao'
        trade_type_hash = {_type: 'TaobaoTrade'}
      when 'taobao_fenxiao'
        trade_type_hash = {_type: 'TaobaoPurchaseOrder'}
      when 'jingdong'
        trade_type_hash = {_type: 'JingdongTrade'}
      when 'shop'
        trade_type_hash = {_type: 'ShopTrade'}

      # 异常订单(仅适用于没有京东订单的dulux)
      when 'unpaid_two_days'
        trade_type_hash = {"$and" => [{:created.lte => Time.now - 2.days},{:pay_time.exists => false},{:status.nin => closed_array}]}
      when 'undispatched_one_day'
        trade_type_hash = {"$and" => [{:pay_time.lte => Time.now - 1.days},{:dispatched_at.exists => false},{:seller_id.exists => false},{:status.in => paid_not_deliver_array}]}
      when 'undelivered_two_days'
        trade_type_hash = {"$and" => [{:dispatched_at.lte => Time.now - 2.days},{"$or" => [{"$and" => [{_type: "TaobaoTrade"}, {:consign_time.exists => false}]}, {"$and" => [{_type: "TaobaoPurchaseOrder"},{"$and" => [{:consign_time.exists => false}, {:delivered_at.exists => false}]}]}]},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]} 
      when 'buyer_delay_deliver', 'seller_ignore_deliver', 'seller_lack_product', 'seller_lack_color', 'buyer_demand_refund', 'buyer_demand_return_product', 'other_unusual_state'
        trade_type_hash = {"unusual_states" => {"$elemMatch" => {key: type, repaired_at: {"$exists" => false}}}}

      # 订单
      when 'all'
        trade_type_hash = nil
      when 'undispatched'
        trade_type_hash = {"$and" =>[{"$or" => [{seller_id: nil},{:seller_id.exists => false}]},{:status.in => paid_not_deliver_array}]}
      when 'unpaid'
        trade_type_hash = {status: "WAIT_BUYER_PAY"}
      when 'undelivered','seller_undelivered'
        trade_type_hash = {"$and" => [{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]}
      when 'delivered','seller_delivered'
        trade_type_hash = {"$and" =>[{:status.in => paid_and_delivered_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'refund'
        trade_type_hash = {has_refund_order: true}
      when 'closed'
        trade_type_hash = {:status.in => closed_array}
      when 'unusual_trade'
        trade_type_hash = {status: "TRADE_NO_CREATE_PAY"}


      # 发货单
      # 发货单是否已打印
      when "deliver_bill_unprinted"
        trade_type_hash = {"$and" => [{:deliver_bill_printed_at.exists => false},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array + paid_and_delivered_array}]}
      when "deliver_bill_printed"
        trade_type_hash = {"$and" => [{:deliver_bill_printed_at.exists => true},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array + paid_and_delivered_array}]}

      # 物流单
      when "logistic_waybill_void"
        trade_type_hash = {"$and" =>[{:logistic_waybill.exists => false},{:status.in => paid_and_delivered_array}]}
      when "logistic_waybill_exist"
        trade_type_hash = {"$and" =>[{:logistic_waybill.exists => true},{:status.in => paid_and_delivered_array}]}
      when "logistic_bill_unprinted"
        trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => false},{:status.in => paid_and_delivered_array}]}
      when "logistic_bill_printed"
        trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => true},{:status.in => paid_and_delivered_array}]}

      # # 发票
      # when 'invoice_all'
      #   trade_type_hash = {:invoice_name.exists => true}
      # when 'invoice_unfilled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => false}
      # when 'invoice_filled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => true}
      # when 'invoice_sent'
      #   trade_type_hash = {"$and" =>[{:status.in => paid_and_delivered_array},{:seller_confirm_invoice_at.exists => true}]}

      # 调色
      when "color_unmatched"
        trade_type_hash = {"$and" => [{has_color_info: false},{:status.in => paid_not_deliver_array}]}
      when "color_matched"
        trade_type_hash = {"$and" => [{has_color_info: true},{:status.in => paid_not_deliver_array},{:confirm_color_at.exists => false}]}
      when "color_confirmed"
        trade_type_hash = {"$and" =>[{has_color_info: true},{:status.in => paid_not_deliver_array},{:confirm_color_at.exists => true}]}

      # 登录时的默认显示
      else
        # 经销商登录默认显示未发货订单
        if current_user.has_role?(:seller)
          trade_type_hash = {"$and" => [{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]}
        end
        # 管理员，客服登录默认显示未分流订单
        if current_user.has_role?(:cs) || current_user.has_role?(:admin)
          trade_type_hash = {"$and" => [{"$or" => [{seller_id: nil},{:seller_id.exists => false}]},{:status.in => paid_not_deliver_array}]}
        end
      end
    end


    ## 筛选
    if params[:search] && !params[:search][:simple_search_option].blank? && !params[:search][:simple_search_value].blank?
      value = /#{params[:search][:simple_search_value].strip}/
      if params[:search][:simple_search_option] == 'seller_id'
        sellers = Seller.where("name like ?", "%#{params[:search][:simple_search_value].strip}%")
        seller_ids = []
        sellers.each {|seller| seller_ids.push seller.nil? ? 0 : seller.id}
        seller_hash = {:seller_id.in => seller_ids}
      elsif params[:search][:simple_search_option] == 'receiver_name'
        receiver_name_hash = {"$or" => [{receiver_name: value}, {"consignee_info.fullname" => value}, {"receiver.name" => value}]}
      elsif params[:search][:simple_search_option] == 'receiver_mobile'
        receiver_mobile_hash = {"$or" => [{receiver_mobile: value}, {"consignee_info.mobile" => value}, {"receiver.mobile_phone" => value}]}
      else
        tid_hash = {tid: value}
      end
    end

    # 发货单打印时间筛选
    if params[:search] && params[:search][:from_deliver_print_date].present? && params[:search][:to_deliver_print_date].present?
      print_start_time = "#{params[:search][:from_deliver_print_date]} #{params[:search][:from_deliver_print_time]}".to_time(form = :local)
      print_end_time = "#{params[:search][:to_deliver_print_date]} #{params[:search][:to_deliver_print_time]}".to_time(form = :local)
      deliver_print_time_hash = {:deliver_bill_printed_at.gte => print_start_time, :deliver_bill_printed_at.lte => print_end_time}
    end

    # 按时间筛选
    if params[:search] && params[:search][:search_start_date].present? && params[:search][:search_end_date].present?
      start_time = "#{params[:search][:search_start_date]} #{params[:search][:search_start_time]}".to_time(form = :local)
      end_time = "#{params[:search][:search_end_date]} #{params[:search][:search_end_time]}".to_time(form = :local)
      create_time_hash = {:created.gte => start_time, :created.lte => end_time}
    end

    # 按付款时间筛选
    if params[:search] && params[:search][:pay_start_date].present? && params[:search][:pay_end_date].present?
      pay_start_time = "#{params[:search][:pay_start_date]} #{params[:search][:pay_start_time]}".to_time(form = :local)
      pay_end_time = "#{params[:search][:pay_end_date]} #{params[:search][:pay_end_time]}".to_time(form = :local)
      pay_time_hash = {:pay_time.gte => pay_start_time, :pay_time.lte => pay_end_time}
    end

    # 按状态筛选
    if params[:search] && params[:search][:status_option].present?
      status_array = params[:search][:status_option].split(",")
      if status_array == ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM"] || status_array == ["WAIT_BUYER_CONFIRM_GOODS_ACOUNTED"]
        status_hash = {"$and" =>[{:status.in => status_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      elsif status_array == ['require_refund']
        status_hash = {has_refund_order: true}
      else
        status_hash = {:status.in => status_array}
      end
    end

    # 按来源筛选
    if params[:search] && params[:search][:type_option].present?
      type_hash = {_type: params[:search][:type_option]}
    end

    # 按省筛选
    if params[:search] && params[:search][:state_option].present?
      state = /#{params[:search][:state_option].delete("省")}/
      receiver_state_hash = {"$or" => [{receiver_state: state}, {"consignee_info.province" => state}, {"receiver.state" => state}]}
    end

    # 按市筛选
    if params[:search] && params[:search][:city_option].present? && params[:search][:city_option] != 'undefined'
      city = /#{params[:search][:city_option].delete("市")}/
      receiver_city_hash = {"$or" => [{receiver_city: city}, {"consignee_info.city" => city}, {"receiver.city" => city}]}
    end

    # 按区筛选
    if params[:search] && params[:search][:district_option].present? && params[:search][:district_option] != 'undefined'
      district = /#{params[:search][:district_option].delete("区")}/
      receiver_district_hash = {"$or" => [{receiver_district: district}, {"consignee_info.county" => district}, {"receiver.district" => district}]}
    end

    # 客服有备注
    if params[:search] && params[:search][:search_cs_memo] == "true"
      has_cs_memo_hash = {has_cs_memo: true}
    end

    # 卖家有备注
    if params[:search] && params[:search][:search_seller_memo] == "true"
      seller_memo_hash = {"$or" => [{"$and" => [{:seller_memo.exists => true}, {:seller_memo.ne => ''}]}, {:delivery_type.exists => true}, {:invoice_info.exists => true}]}
    end

    # 客户有留言
    if params[:search] && params[:search][:search_buyer_message] == "true"
      buyer_message_hash = {"$and" => [{:buyer_message.exists => true}, {:buyer_message.ne => ''}]}
    end

    # 需要开票
    if params[:search] && params[:search][:search_invoice] == "true"
      invoice_all_hash = {"$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}]}
    end

    # 需要调色
    if params[:search] && params[:search][:search_color] == "true"
      has_color_info_hash = {has_color_info: true}
    end

    # 按经销商筛选
    if params[:search] && !params[:search][:search_logistic].blank? && params[:search][:search_logistic] != 'null'
      logi_name = /#{params[:search][:search_logistic].strip}/
      logistic_hash = {logistic_name: logi_name}
    end

    # 集中筛选
    if params[:search]
      search_hash = {"$and" => [
        seller_hash, tid_hash, receiver_name_hash, receiver_mobile_hash,
        deliver_print_time_hash, create_time_hash, pay_time_hash,
        status_hash, type_hash, logistic_hash,
        seller_memo_hash, buyer_message_hash, has_color_info_hash, has_cs_memo_hash, invoice_all_hash,
        receiver_state_hash, receiver_city_hash, receiver_district_hash,
        ].compact}
      search_hash == {"$and"=>[]} ? search_hash = nil : search_hash
    end

    ## 过滤有留言但还在抓取 + 总筛选
      chief_hash = {"$and" =>[trade_type_hash, search_hash, {"$or" => [{:has_buyer_message.ne => true}, {:buyer_message.ne => nil}]}].compact}
      unless chief_hash == {"$and"=>[]}
        @trades = @trades.where(chief_hash)
      end

    ###筛选结束###

    @trades_count = @trades.count
    offset = params[:offset] || 0
    limit = params[:limit] || 20
    @trades = TradeDecorator.decorate(@trades.limit(limit).offset(offset).order_by("created", "DESC"))
    if @trades.count > 0
      respond_with @trades
    else
      render json: []
    end
  end

  def notifer
    trade_type = params[:trade_type]
    timestamp = Time.at(params[:timestamp].to_i)

    @trades = Trade

    if current_user.has_role?(:seller)
      unless current_user.seller == nil
        @trades = @trades.where seller_id: current_user.seller.try(:id)
      else
        render json: []
        return
      end
    end

    case params[:trade_type]
    when 'taobao'
      trade_type = 'TaobaoTrade'
    when 'taobao_fenxiao'
      trade_type = 'TaobaoPurchaseOrder'
    when 'jingdong'
      trade_type = 'JingdongTrade'
    when 'shop'
      trade_type = 'ShopTrade'
    else
      trade_type = nil
    end

    if trade_type
      @trades = @trades.where(_type: trade_type)
    end

    @new_trades_count = @trades.where(:created.gt => timestamp).count
    render json: @new_trades_count
  end

  def show
    @trade = TradeDecorator.decorate(Trade.where(_id: params[:id]).first)
    @splited_orders = matched_seller_info(@trade)
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first
    notifer_seller_flag = false

    if params[:seller_id].present?
      seller = Seller.find_by_id params[:seller_id]
      @trade.dispatch!(seller) if seller
    elsif params[:seller_id].nil?
      @trade.reset_seller
    end

    if params[:delivered_at] == true
      logistic = Logistic.find_by_id params[:logistic_info]
      @trade.logistic_id = logistic.id
      @trade.logistic_name = logistic.name
      @trade.logistic_code = logistic.code
      if @trade.logistic_code == "OTHER"
        @trade.logistic_waybill = params[:logistic_waybill].present? ? params[:logistic_waybill] : @trade.tid
      end  
      @trade.delivered_at = Time.now
    end

    unless params[:cs_memo].blank?
      @trade.cs_memo = params[:cs_memo].strip
      if @trade.changed.include? 'cs_memo'
        notifer_seller_flag = true
      end
    end

    unless params[:gift_memo].blank?
      @trade.gift_memo = params[:gift_memo].strip
    end

    unless params[:invoice_type].blank?
      @trade.invoice_type = params[:invoice_type].strip
    end

    unless params[:invoice_name].blank?
      @trade.invoice_name = params[:invoice_name].strip
    end

    unless params[:invoice_content].blank?
      @trade.invoice_content = params[:invoice_content].strip
    end

    unless params[:invoice_date].blank?
      @trade.invoice_date = params[:invoice_date].strip
    end

    unless params[:invoice_number].blank?
      @trade.invoice_number = params[:invoice_number].strip
    end

    if params[:seller_confirm_deliver_at] == true
      @trade.seller_confirm_deliver_at = Time.now
    end

    if params[:seller_confirm_invoice_at] == true
      @trade.seller_confirm_invoice_at = Time.now
    end

    unless params[:reason].blank?
      state = @trade.unusual_states.build(reason: params[:reason], plan_repair_at: params[:plan_repair_at], note: params[:state_note], created_at: Time.now, reporter: current_user.name)
      state.update_attributes(key: state.add_key)
    end

    unless params[:state_id].blank?
      state = @trade.unusual_states.find params[:state_id]
      state.repair_man = current_user.name
      state.repaired_at = Time.now
    end

    if params[:confirm_color_at] == true
      @trade.confirm_color_at = Time.now
    end

    if params[:confirm_check_goods_at] == true
      @trade.confirm_check_goods_at = Time.now
    end

    if params[:confirm_receive_at] == true
      @trade.confirm_receive_at = Time.now
    end

    if params[:request_return_at] == true
      @trade.request_return_at = Time.now
    end

    if params[:confirm_return_at] == true
      @trade.confirm_return_at = Time.now
    end

    if params[:confirm_refund_at] == true
      @trade.confirm_refund_at = Time.now
    end

    if params[:logistic_waybill].present?
      @trade.logistic_waybill = params[:logistic_waybill]
    end

    if params[:logistic_memo].present?
      @trade.logistic_memo = params[:logistic_memo]
    end

    if params[:deliver_bill_printed_at] == true
      @trade.deliver_bill_printed_at = Time.now
    end

    unless params[:orders].blank?
      params[:orders].each do |item|
        order = @trade.orders.find item[:id]
        order.cs_memo = item[:cs_memo]
        if order.changed.include? 'cs_memo'
          notifer_seller_flag = true
        end
        item[:color_num].each_with_index do |num, index|
          if num.blank?
            order.color_num[index] = nil
            order.color_hexcode[index] = nil
            order.color_name[index] = nil
          else
            order.color_num[index] = num
            color = Color.find_by_num num
            order.color_hexcode[index] = color.try(:hexcode)
            order.color_name[index] = color.try(:name)
          end
        end
        item[:barcode].each_with_index do |code, index|
          order.barcode[index] = code
        end
      end
    end

    if @trade.save!
      @trade = TradeDecorator.decorate(@trade)
      if notifer_seller_flag && @trade.status == "WAIT_SELLER_SEND_GOODS" && @trade.seller
        TradeDispatchEmail.perform_async(@trade.id, @trade.seller_id, 'second')
        TradeDispatchSms.perform_async(@trade.id, @trade.seller_id, 'second')
      end
      unless params[:operation].blank?
        @trade.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: params[:operation])
      end
      respond_with(@trade) do |format|
        format.json { render :show, status: :ok }
      end
    else
      head :unprocessable_entity
    end
  end

  def seller_for_area
    trade = Trade.find params[:id]
    area = Area.find params[:area_id]
    if TradeSetting.company == 'dulux'
      seller = Dulux::SellerMatcher.match_trade_seller(trade, area)
      seller ||= trade.default_area.sellers.where(active: true).first
    else
      seller = trade.matched_seller_with_default(area)
    end
    seller_id = nil
    seller_name = '无对应经销商'
    dispatchable = false

    if seller
      seller_id = seller.id
      seller_name = seller.name
      dispatchable = true
      errors = can_lock_products?(trade, seller.id).join(',')
      unless errors.blank?
        seller_name += "(无法分流：#{errors})"
        dispatchable = false
      end
    end

    respond_to do |format|
      format.json { render json: {seller_id: seller_id, seller_name: seller_name, dispatchable: dispatchable} }
    end
  end

  def new
    @trade = Trade.new
  end

  def create
    @trade = TaobaoTrade.new(params[:trade])
    @trade.taobao_orders.build(params[:orders])
    @trade.created = Time.now
    @trade.tid = "000000" + Time.now.to_i.to_s
    @trade.taobao_orders.first.total_fee = 1
    if @trade.save
      redirect_to "/app#trades"
    else
      render trades_new_path
    end
  end

  def sellers_info
    trade = Trade.find params[:id]
    logger.debug matched_seller_info(trade).inspect
    respond_to do |format|
      format.json { render json: matched_seller_info(trade) }
    end
  end

  def split_trade
    trade = Trade.find params[:id]
    new_trade_ids = split_orders(trade)
    trade.operation_logs.create(operated_at: Time.now, operation: '拆单')
    respond_to do |format|
      format.json { render json: {ids: new_trade_ids} }
    end
  end

  def print_bill
    @trade = Trade.find params[:id]
  end
end
