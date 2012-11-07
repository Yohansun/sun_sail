# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  layout false, :only => :print_deliver_bill
  before_filter :authenticate_user!
  respond_to :json, :xls
  include Dulux::Splitter
  include TaobaoProductsLockable

  def index
    offset = params[:offset] || 0
    limit = params[:limit] || 20
    @trades = Trade.filter(current_user, params)
    @trades_count = @trades.count
    @trades = TradeDecorator.decorate(@trades.limit(limit).offset(offset).order_by("created", "DESC"))
    if @trades_count > 0
      respond_with @trades
    else
      render json: []
    end
  end

  def export
    @report = TradeReport.new
    @report.request_at = Time.now
    @report.user_id = current_user.id
    @report.conditions = params.select {|k,v| !['limit','offset', 'action', 'controller'].include?(k)  } 
    @report.save
    @report.export_report
    respond_to do |format|
      format.js
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

  def print_deliver_bill
    @trades = Trade.find(params[:ids].split(','))
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def logistic_info
    @trade = Trade.find params[:id]
    xml = Logistic.find_by_id(@trade.logistic_id).try(:xml)
    xml ||= @trade.matched_logistics.select{ |e| e[2].present? }.first.try(:at, 2)
    render text: xml
  end

  def deliver_list
    list = []
    Trade.find(params[:ids]).each do |trade|
      list << {
        name: trade.receiver_name,
        tid: trade.tid,
        address: "#{trade.receiver_state} #{trade.receiver_city} #{trade.receiver_district} #{trade.receiver_address}",
        logistic_name: trade.logistic_name || '',
        logistic_waybill: trade.logistic_waybill || ''
      }
    end

    respond_to do |format|
      format.json { render json: list }
    end
  end

  def setup_logistics
    flag = true
    if params[:data].present?
      params[:data].values.each do |trade|
        a = trade
        trade = Trade.where(tid: a['tid']).first
        trade.logistic_code = 'OTHER'
        trade.logistic_waybill = a["logistic"]
        trade.logistic_name = '圆通'
        trade.logistic_id = 3
        trade.save!
      end
    else
      flag =false
    end

    render json: {isSuccess: flag}
  end

  def batch_deliver
    flag = true
    if params[:ids].present?
      params[:ids].each do |id|
        trade = Trade.find(id)
        next unless trade
        trade.status = 'WAIT_BUYER_CONFIRM_GOODS'
        trade.delivered_at = Time.now
        trade.save
      end
    else
      flag =false
    end

    render json: {isSuccess: flag}
  end

  def batch_print_deliver
    success = Trade.any_in(_id: params[:ids]).update_all(deliver_bill_printed_at: Time.now)
    render json: {isSuccess: success}
  end

  def batch_print_logistic
    logistic = Logistic.find_by_id params[:logistic]
    success = true
    Trade.any_in(_id: params[:ids]).each do |trade|
      trade.logistic_printed_at = Time.now

      # 只记录 暂不做修改
      # if trade.logistic_waybill.blank?
      #   trade.logistic_id = logistic.try(:id)
      #   trade.logistic_name = logistic.try(:name)
      #   trade.logistic_code = logistic.try(:code)
      # end

      success = false unless trade.save
    end

    render json: {isSuccess: success}    
  end
end
