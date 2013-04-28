# encoding: utf-8

# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  layout false, :only => :print_deliver_bill
  before_filter :authenticate_user!
  respond_to :json, :xls
  before_filter :authorize,:only => [:index,:print_deliver_bill]

  include StockProductsLockable
  #include Dulux::Splitter

  def index
    offset = params[:offset] || 0
    limit = params[:limit] || 20
    @trades = Trade.filter(current_account, current_user, params)
    @trades_count = @trades.count

    @trades = TradeDecorator.decorate(@trades.limit(limit).skip(offset).order_by(:created.desc))
    if @trades_count > 0
      respond_with @trades
    else
      render json: []
    end
  end

  def export
    @report = TradeReport.new
    @report.account_id = current_account.id
    @report.request_at = Time.now
    @report.user_id = current_user.id
    if params['search']
      params['search'] =  params['search'] .select {|k,v| v != "undefined"  }
      params['search'].each do |k,v|
        params['search'][k]  = v.encode('UTF-8','GBK') rescue "bad encoding"
      end
    end
    @report.conditions = params.select {|k,v| !['limit','offset', 'action', 'controller'].include?(k)}
    #目前只有立邦具有多种订单
    if current_account.key == "nippon" && @report.conditions.fetch("search").fetch("_type").blank?
      render :js => "alert('导出报表之前请在高级搜索中选择订单来源');$('.export_orders_disabled').addClass('export_orders').removeClass('export_orders_disabled disabled');"
    else
      @report.save
      @report.export_report
      respond_to do |format|
        format.js
      end
    end
  end

  def notifer
    trade_type = params[:trade_type]
    timestamp = Time.at(params[:timestamp].to_i)

    @trades = Trade

    if current_user.seller.present?
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
    # if params[:splited]
    #   @splited_orders = matched_seller_info(@trade)
    # end
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first
    notifer_seller_flag = false

    if params[:seller_id].present?
      seller = current_account.sellers.find_by_id params[:seller_id]
      @trade.dispatch!(seller) if seller
    elsif params[:seller_id].nil?
      @trade.reset_seller
    end

    if params[:delivered_at] == true
      @trade.delivered_at = Time.now
      @trade.status = 'WAIT_BUYER_CONFIRM_GOODS'
      if params['logistic_info'] == '其他' and @trade.logistic_waybill.nil?
        logistic = current_account.logistics.find_by_name '其他'
        if logistic
          @trade.logistic_waybill = @trade.tid
          @trade.logistic_name = logistic.name
          @trade.logistic_code = logistic.code
          @trade.logistic_id = logistic.id
        end
      end
    end

    if params[:setup_logistic] == true
      logistic = current_account.logistics.find_by_id params[:logistic_id]
      @trade.logistic_id = logistic.try(:id)
      @trade.logistic_name = logistic.try(:name)
      @trade.logistic_code = logistic.try(:code)
      @trade.logistic_waybill = params[:logistic_waybill].present? ? params[:logistic_waybill] : @trade.tid
    end

    if params[:cs_memo]
      @trade.cs_memo = params[:cs_memo].strip
      if @trade.changed.include? 'cs_memo'
        notifer_seller_flag = true
      end
    end

    # 赠品更新
    @trade.gift_memo = params[:gift_memo].strip if params[:gift_memo]
    if params[:delete_gifts]
      params[:delete_gifts].each do |gift_tid|
        trade_gift = @trade.trade_gifts.where(gift_tid: gift_tid).first
        if trade_gift
          Trade.where(tid: gift_tid).first.delete if trade_gift.delivered_at == nil && trade_gift.trade_id.present?
          @trade.trade_gifts.where(gift_tid: gift_tid).first.delete
        end
      end
    end
    if params[:add_gifts]
      params[:add_gifts].each do |key, value|
        if value['trade_id'].present? #NEED ADAPTION?
          fields = @trade.fields_for_gift_trade
          fields["tid"] = value['gift_tid']
          fields["main_trade_id"] = value['trade_id']
          gift_trade = CustomTrade.create(fields)
          gift_trade.add_gift_order(value)
        else
          @trade.add_gift_order(value)
        end
        @trade.trade_gifts.create!(value)
      end
    end

    @trade.invoice_type = params[:invoice_type].strip if params[:invoice_type]
    @trade.invoice_name = params[:invoice_name].strip if params[:invoice_name]
    @trade.invoice_content = params[:invoice_content].strip if params[:invoice_content]
    @trade.invoice_date = params[:invoice_date].strip if params[:invoice_date]
    @trade.invoice_number = params[:invoice_number].strip if params[:invoice_number]

    if params[:seller_confirm_deliver_at] == true
      @trade.seller_confirm_deliver_at = Time.now
    end

    if params[:seller_confirm_invoice_at] == true
      @trade.seller_confirm_invoice_at = Time.now
    end

    unless params[:reason].blank?
      state = @trade.unusual_states.create!(reason: params[:reason], plan_repair_at: params[:plan_repair_at], note: params[:state_note], created_at: Time.now, reporter: current_user.name, repair_man: params[:repair_man])
      state.update_attributes(key: state.add_key)
      role_key = current_user.roles.first.name
      state.update_attributes!(reporter_role: role_key)
    end

    unless params[:state_id].blank?
      state = @trade.unusual_states.find params[:state_id]
      state.repair_man = current_user.name
      state.repaired_at = Time.now
    end

    if params[:logistic_ids].present?
      @trade.split_logistic(params[:logistic_ids])
    end

    if params[:confirm_color_at] == true
      @trade.confirm_color_at = Time.now
    end

    if params[:confirm_check_goods_at] == true
      @trade.confirm_check_goods_at = Time.now
    end

    if params[:confirm_receive_at] == true
      @trade.confirm_receive_at = Time.now
      @trade.status = 'TRADE_FINISHED' if @trade._type = "CustomTrade"
    end

    if params[:request_return_at] == true
      @trade.request_return_at = Time.now
      trade_decorator = TradeDecorator.decorate(@trade)
      content = "#{@trade.seller.try(:name)}经销商您好，您有一笔退货订单需要处理。订单号：#{@trade.tid}，买家姓名：#{trade_decorator.receiver_name}，手机：#{trade_decorator.receiver_mobile_phone}，请尽快登录系统查看！"
      SmsNotifier.perform_async(content, @trade.seller.try(:mobile), @trade.tid, 'request_return')
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

    if params[:modify_payment]
      @trade.modify_payment = params[:modify_payment]
    end

    if params[:modify_payment_at]
      @trade.modify_payment_at = params[:modify_payment_at]
    end

    if params[:modify_payment_memo]
      @trade.modify_payment_memo = params[:modify_payment_memo]
    end

    if params[:modify_payment_no]
      @trade.modify_payment_no = params[:modify_payment_no]
    end

    unless params[:orders].blank?
      params[:orders].each do |item|
        order = @trade.orders.where(_id: item[:id]).first
        if order
          order.cs_memo = item[:cs_memo]
          if order.changed.include? 'cs_memo'
            notifer_seller_flag = true
          end
          if item[:color_num]
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
          end
          if item[:barcode]
            item[:barcode].each_with_index do |code, index|
              order.barcode[index] = code
            end
          end
        end
      end
    end

    unless params[:notify_content].blank?
      notify = @trade.manual_sms_or_emails.create(notify_sender: params[:notify_sender],
                                          notify_receiver: params[:notify_receiver],
                                          notify_theme: params[:notify_theme],
                                          notify_content: params[:notify_content],
                                          notify_type: params[:notify_type] )
    end

    if @trade.save
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

    seller = SellerMatcher.match_trade_seller(trade, area)
    seller ||= trade.default_seller

    seller_id = nil
    seller_name = '无对应经销商'
    dispatchable = false

    if seller
      seller_id = seller.id
      seller_name = seller.name
      dispatchable = true
      errors = can_lock_products?(trade, seller.id).join(',')
      if errors.present?
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
    @trade.account_id = current_account.id
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
    @trade = Trade.find params[:id]
    new_trade_ids = if current_account.key == 'dulux'
      split_orders(@trade)
    else
      TradeSplitter.new(@trade).split!
    end

    @trade.operation_logs.build(operated_at: Time.now, operation: '拆单', operator_id: current_user.id, operator: current_user.name)
    respond_to do |format|
      format.json { render json: {ids: new_trade_ids} }
    end
  end

  def print_deliver_bill
    @trades = Trade.find(params[:ids].split(','))
    respond_to do |format|
      format.html
    end
  end

  def deliver_list
    respond_to do |format|
      format.json { render json: Trade.find(params[:ids]).to_json }
    end
  end

  def batch_deliver
    Trade.any_in(_id: params[:ids]).each do |trade|
      trade.delivered_at = Time.now
      trade.status = "WAIT_BUYER_CONFIRM_GOODS"
      trade.save # this will trigger observer.
    end
    render json: {isSuccess: true}
  end

  def recover
    trade = Trade.find params[:id]
    parent_trade = Trade.deleted.where(tid: trade.tid, splitted_tid: nil).first

    success = if parent_trade
      Trade.where(tid: trade.tid).delete_all
      parent_trade.operation_logs.build(operated_at: Time.now, operation: '订单合并')
      parent_trade.save
      parent_trade.restore
    end

    respond_to do |format|
      format.json { render json: {is_success: success.present? } }
    end
  end
end
