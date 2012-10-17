# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :xls
  include Dulux::Splitter
  include TaobaoProductsLockable

  def index
    @trades = Trade
    seller = current_user.seller
    logistic = current_user.logistic

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

    case params[:trade_type]
    when 'taobao'
      trade_type = 'TaobaoTrade'
    when 'taobao_fenxiao'
      trade_type = 'TaobaoPurchaseOrder'
    when 'jingdong'
      trade_type = 'JingdongTrade'
    when 'shop'
      trade_type = 'ShopTrade'

    ## 异常订单筛选(仅适用于没有京东订单的dulux)
    when 'unpaid_two_days'
      unusual_trade_hash_1 = {"$and" => [{:created.lte => Time.now - 2.days},{:pay_time.exists => false}]}
    when 'undispatched_one_day'
      unusual_trade_hash_2 = {"$and" => [{:pay_time.lte => Time.now - 1.days},{:dispatched_at.exists => false}]}
    when 'undelivered_two_days'
      unusual_trade_hash_3 = {"$and" => [{:dispatched_at.lte => Time.now - 2.days},{"$or" => [{"$and" => [{_type: "TaobaoTrade"}, {:consign_time.exists => false}]}, {"$and" => [{_type: "TaobaoPurchaseOrder"},{"$and" => [{:consign_time.exists => false}, {:delivered_at.exists => false}]}]}]}]}
    when 'buyer_delay_deliver'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "buyer_delay_deliver"}}}
    when 'seller_ignore_deliver'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "seller_ignore_deliver"}}}
    when 'seller_lack_product'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "seller_lack_product"}}}
    when 'seller_lack_color'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "seller_lack_color"}}}
    when 'buyer_demand_refund'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "buyer_demand_refund"}}}
    when 'buyer_demand_return_product'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "buyer_demand_return_product"}}}
    when 'other_unusual_state'
      unusual_trade_hash = {"unusual_states" => {"$elemMatch" => {key: "other_unusual_state"}}}
    else
      trade_type = nil
      unusual_trade_hash = nil
    end

    if trade_type
      @trades = @trades.where(_type: trade_type)
    end

    if unusual_trade_hash
      @trades = @trades.where(unusual_trade_hash)
    end

    if unusual_trade_hash_1
      @trades = @trades.where(unusual_trade_hash_1)
      @trades = @trades.where(:status.nin => ["TRADE_CLOSED_BY_TAOBAO"])
    end
    
    if unusual_trade_hash_2
      @trades = @trades.where(unusual_trade_hash_2)
      @trades = @trades.where("$or" => [{seller_id: nil},{:seller_id.exists => false}])
      @trades = @trades.where(:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"])
    end

    if unusual_trade_hash_3
      @trades = @trades.where(unusual_trade_hash_3)
      @trades = @trades.where("$and" => [{:dispatched_at.ne => nil},{:dispatched_at.exists => true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]}])
    end

    ###筛选###

    ## 导航栏筛选

    # 订单
    if !params[:search_trade_status].blank? && params[:search_trade_status] != 'null'
      status = params[:search_trade_status]
      if status == 'undispatched'
        @trades = @trades.where("$or" => [{seller_id: nil},{:seller_id.exists => false}])
        @trades = @trades.where(:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"])
      elsif status == 'unpaid'
        @trades = @trades.where(:status.in => ["WAIT_BUYER_PAY"])
      elsif status == 'undelivered'
        @trades = @trades.where("$and" => [{:dispatched_at.ne => nil},{:dispatched_at.exists => true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]}])
      elsif status == 'delivered'
        @trades = @trades.where(:status.in => ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"])
      elsif status == 'refund'
        @trades = @trades.where(:status.in => ["TRADE_REFUNDING","WAIT_SELLER_AGREE","SELLER_REFUSE_BUYER","WAIT_BUYER_RETURN_GOODS","WAIT_SELLER_CONFIRM_GOODS","CLOSED", "SUCCESS"])
      elsif status == 'closed'
        @trades = @trades.where(:status.in => ["TRADE_CLOSED","TRADE_CANCELED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"])
      elsif status == 'unusual_trade'
        @trades = @trades.where(:status.in => ["TRADE_NO_CREATE_PAY"])
      end
    end

    # 经销商登录默认显示未分流订单
    if params[:search_trade_status].blank? && params[:search].blank? && params[:search_all].blank? && current_user.has_role?(:seller)
      @trades = @trades.where("$and" => [{:dispatched_at.ne => nil},{:dispatched_at.exists => true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]}])
    end

    # 客服登录默认显示未分流订单
    if params[:search_trade_status].blank? && params[:search].blank? && params[:search_all].blank? && current_user.has_role?(:cs)
      @trades = @trades.where("$or" => [{seller_id: nil},{:seller_id.exists => false}])
      @trades = @trades.where(:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"])
    end

    # 发货单
    # 发货单是否已打印
    if params[:search_deliverbill_status] == "deliver_bill_unprinted"
      @trades = @trades.where(:deliver_bill_printed_at.exists => false)
    elsif params[:search_deliverbill_status] == "deliver_bill_printed"
      @trades = @trades.where(:deliver_bill_printed_at.exists => true)
    end

    # 物流单
    # 物流单是否已打印
    if params[:logistic_status] == "logistic_all"
    elsif params[:logistic_status] == "logistic_unprinted"
      @trades = @trades.where(:logistic_printed_at.exists => false)
    elsif params[:logistic_status] == "logistic_printed"
      @trades = @trades.where(:logistic_printed_at.exists => true)
    end

    #发票
    if params[:search_invoice_status] == 'invoice_all'
      @trades = @trades.where("$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}])
    elsif params[:search_invoice_status] == 'invoice_unfilled'
      @trades = @trades.where(:seller_confirm_invoice_at.exists => false)
    elsif params[:search_invoice_status] == 'invoice_filled'
      @trades = @trades.where(:seller_confirm_invoice_at.exists => true)
    elsif params[:search_invoice_status] == 'invoice_sent'
      @trades = @trades.where("$and" =>[{:status.in => ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"]},{:seller_confirm_invoice_at.exists => true}])
    end

    # 调色
    if params[:search_color_status] == "unmatched"
      @trades = @trades.where("$and" => [{has_color_info: false},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]}])
    elsif params[:search_color_status] == "matched"
      @trades = @trades.where("$and" => [{has_color_info: true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]},{:confirm_color_at.exists => false}])
    elsif params[:search_color_status] == "confirmed"
      @trades = @trades.where("$and" =>[{has_color_info: true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]},{:confirm_color_at.exists => true}])
    end

    ## 简单筛选
    if params[:search] && !params[:search][:option].blank? && params[:search][:option] != 'null' && params[:search][:value] != 'null' && !params[:search][:value].blank?
      value = /#{params[:search][:value].strip}/
      if params[:search][:option] == 'seller_id'
        sellers = Seller.where("name like ?", "%#{params[:search][:value].strip}%")
        seller_ids = []
        sellers.each {|seller| seller_ids.push seller.nil? ? 0 : seller.id}
        @trades = @trades.where(:seller_id.in => seller_ids)
      elsif params[:search][:option] == 'receiver_name'
        receiver_name_hash = {"$or" => [{receiver_name: value}, {"consignee_info.fullname" => value}, {"receiver.name" => value}]}
      elsif params[:search][:option] == 'receiver_mobile'
        receiver_mobile_hash = {"$or" => [{receiver_mobile: value}, {"consignee_info.mobile" => value}, {"receiver.mobile_phone" => value}]}
      else
        @trades = @trades.where(Hash[params[:search][:option].to_sym, value])
      end
    end


    ##高级搜索

    # 按时间筛选
    if params[:search_all] && params[:search_all][:search_start_date].present? && params[:search_all][:search_end_date].present?
      start_time = "#{params[:search_all][:search_start_date]} #{params[:search_all][:search_start_time]}".to_time(form = :local)
      end_time = "#{params[:search_all][:search_end_date]} #{params[:search_all][:search_end_time]}".to_time(form = :local)
      @trades = @trades.where(:created.gte => start_time, :created.lte => end_time)
    end

    # 按付款时间筛选
    if params[:search_all] && params[:search_all][:pay_start_date].present? && params[:search_all][:pay_end_date].present?
      pay_start_time = "#{params[:search_all][:pay_start_date]} #{params[:search_all][:pay_start_time]}".to_time(form = :local)
      pay_end_time = "#{params[:search_all][:pay_end_date]} #{params[:search_all][:pay_end_time]}".to_time(form = :local)
      @trades = @trades.where(:pay_time.gte => pay_start_time, :pay_time.lte => pay_end_time)
    end

    # 按状态筛选
    if params[:search_all] && params[:search_all][:status_option].present?
        status_array = params[:search_all][:status_option].split(",")
        @trades = @trades.where(:status.in => status_array)
    end

    # 按来源筛选
    if params[:search_all] && params[:search_all][:type_option].present?
      @trades = @trades.where(_type: params[:search_all][:type_option])
    end

    # 按省筛选
    if params[:search_all] && params[:search_all][:state_option].present?
      state = /#{params[:search_all][:state_option].delete("省")}/
      receiver_state_hash = {"$or" => [{receiver_state: state}, {"consignee_info.province" => state}, {"receiver.state" => state}]}
    end

    # 按市筛选
    if params[:search_all] && params[:search_all][:city_option].present? && params[:search_all][:city_option] != 'undefined'
      city = /#{params[:search_all][:city_option].delete("市")}/
      receiver_city_hash = {"$or" => [{receiver_city: city}, {"consignee_info.city" => city}, {"receiver.city" => city}]}
    end

    # 按区筛选
    if params[:search_all] && params[:search_all][:district_option].present? && params[:search_all][:district_option] != 'undefined'
      district = /#{params[:search_all][:district_option].delete("区")}/
      receiver_district_hash = {"$or" => [{receiver_district: district}, {"consignee_info.county" => district}, {"receiver.district" => district}]}
    end

    # 客服有备注
    if params[:search_all] && params[:search_all][:search_cs_memo] == "true"
      @trades = @trades.where(:cs_memo.exists => true)
    end

    # 卖家有备注
    if params[:search_all] && params[:search_all][:search_seller_memo] == "true"
      seller_memo_hash = {"$or" => [{"$and" => [{:seller_memo.exists => true}, {:seller_memo.ne => ''}]}, {:delivery_type.exists => true}, {:invoice_info.exists => true}]}
    end

    # 客户有留言
    if params[:search_all] && params[:search_all][:search_buyer_message] == "true"
      buyer_message_hash = {"$and" => [{:buyer_message.exists => true}, {:buyer_message.ne => ''}]}
    end

    # 需要开票
    if params[:search_all] && params[:search_all][:search_invoice] == "true"
        invoice_all_hash = {"$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}]}
    end

    # 需要调色
    if params[:search_all] && params[:search_all][:search_color] == "true"
      @trades = @trades.where(has_color_info: true)
    end

    # 按经销商筛选
    if params[:search_all] && !params[:search_all][:search_logistic].blank? && params[:search_all][:search_logistic] != 'null'
      logi_name = /#{params[:search_all][:search_logistic].strip}/
      @trades = @trades.where(logistic_name: logi_name)
    end


    # 高级搜索$or,$and集中筛选
    if (params[:search_all] && (params[:search_all][:state_option].present? || (params[:search_all][:city_option].present? && params[:search_all][:city_option] != 'undefined') || (params[:search_all][:district_option].present? && params[:search_all][:district_option] != 'undefined') || params[:search_all][:search_invoice] == "true" || params[:search_all][:search_seller_memo] == "true" || params[:search_all][:search_buyer_message] == "true")) || (params[:search] && (params[:search][:option] == 'receiver_name' || params[:search][:option] == 'receiver_mobile'))
      @trades = @trades.where("$and" => [receiver_name_hash, receiver_mobile_hash, seller_memo_hash, buyer_message_hash, invoice_all_hash, receiver_state_hash, receiver_city_hash, receiver_district_hash].compact)
    end


    #过滤有留言但还在抓取
    @trades = @trades.where("$or" => [{:has_buyer_message.ne => true}, {:buyer_message.ne => nil}])

    ###筛选结束###

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
    logger.debug @splited_orders.inspect
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first

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
      #@trade.logistic_code = params[:logistic_code]
      @trade.logistic_waybill = params[:logistic_waybill]
      @trade.delivered_at = Time.now
    end

    unless params[:cs_memo].blank?
      @trade.cs_memo = params[:cs_memo].strip
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
      state = @trade.unusual_states.build(reason: params[:reason], created_at: Time.now, reporter: current_user.name)
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

    if params[:logistic_waybill].present?
      @trade.logistic_waybill = params[:logistic_waybill]
    end

    if params[:logistic_memo].present?
      @trade.logistic_memo = params[:logistic_memo]
    end

    unless params[:orders].blank?
      params[:orders].each do |item|
        order = @trade.orders.find item[:id]
        order.cs_memo = item[:cs_memo]
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

    unless params[:operation].blank?
      @trade.operation_logs.build(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: params[:operation])
    end

    if @trade.save
      @trade = TradeDecorator.decorate(@trade)
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
      redirect_to "/trades"
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
    split_hash = params[:split_result].values
    new_trade_ids = split_orders(trade, false, split_hash)

    respond_to do |format|
      format.json { render json: {ids: new_trade_ids} }
    end
  end
end
