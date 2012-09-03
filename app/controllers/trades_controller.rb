# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :xls

  def index
    @trades = Trade

    if current_user.role_key == 'seller'
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

    
    ###筛选###

    # 简单筛选
    if params[:search] && !params[:search][:option].blank? && params[:search][:option] != 'null'
      if params[:search][:option] == 'seller_id'
        seller = Seller.where(name: params[:search][:value]).first
        seller_id = seller.nil? ? 0 : seller.id
        @trades = @trades.where(seller_id: seller_id)
      else
        @trades = @trades.where(Hash[params[:search][:option].to_sym, params[:search][:value]])
      end
    end

    # 按时间筛选
    if params[:search_all] && !params[:search_all][:search_start_date].blank? && params[:search_all][:search_start_date] != 'null' && !params[:search_all][:search_end_date].blank? && params[:search_all][:search_end_date] != 'null'
      start_time = (params[:search_all][:search_start_date] + ' ' + params[:search_all][:search_start_time]).to_time(form = :local)
      end_time = (params[:search_all][:search_end_date] + ' ' + params[:search_all][:search_end_time]).to_time(form = :local)
      @trades = @trades.where(:created.gte => start_time, :created.lte => end_time)
    end

    # 按状态筛选
    if params[:search_all] && !params[:search_all][:status_option].blank? && params[:search_all][:status_option] != 'null'
      if params[:search_all][:status_option] == 'undispatched_trade'
        @trades = @trades.where(:dispatched_at.exists => false)
      elsif params[:search_all][:status_option] == 'unusual_trade'
        #异常订单
      else
        status_array = params[:search_all][:status_option].split(",")
        @trades = @trades.where(:status.in => status_array)
      end
    end

    # 按来源筛选
    if params[:search_all] && !params[:search_all][:type_option].blank? && params[:search_all][:type_option] != 'null'
      @trades = @trades.where(_type: params[:search_all][:type_option])
    end

    # 客服有备注
    if params[:search_all] && params[:search_all][:search_cs_memo] == "true"
      @trades = @trades.where(:cs_memo.exists => true)
    end

    # 卖家有备注
    if params[:search_all] && params[:search_all][:search_seller_memo] == "true"
      @trades = @trades.where("$or" => [{"$and" => [{:seller_memo.exists => true}, {:seller_memo.ne => ''}]}, {:delivery_type.exists => true}, {:invoice_info.exists => true}])
    end
    
    # 客户有留言
    if params[:search_all] && params[:search_all][:search_buyer_message] == "true"
      @trades = @trades.where("$and" => [{:buyer_message.exists => true}, {:buyer_message.ne => ''}])
    end

    # 需要开票+按发票状态筛选
    if params[:search_all]
      if params[:search_all][:search_invoice] == "true" || params[:search_all][:search_invoice] == 'invoice_all'
        @trades = @trades.where("$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}])
      elsif params[:search_all][:search_invoice] == 'invoice_unfilled'
        @trades = @trades.where("$or" => [{:invoice_name.exists => false},{:invoice_type.exists => false},{:invoice_content.exists => false},{:invoice_date.exists => false}])
      elsif params[:search_all][:search_invoice] == 'invoice_filled'
        @trades = @trades.where(:seller_confirm_invoice_at.exists => true)
      elsif params[:search_all][:search_invoice] == 'invoice_sent'
        @trades = @trades.where("$and" =>[{:status.in => ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"]},{:seller_confirm_invoice_at.exists => true}])
      end
    end

    # 需要配色
    if params[:search_all] && params[:search_all][:search_color] == "true"
      trade_id = []
      @trades.all.each do |t|
        if t.has_color_info == true
          trade_id += t.tid.to_a
        end
      end
      @trades = @trades.where(:tid.in => trade_id)
    end

    # 出货单是否已打印
      if params[:search_deliverbill_status] == "deliver_bill_unprinted"
        @trades = @trades.where(:deliver_bill_printed_at.exists => false)
      elsif params[:search_deliverbill_status] == "deliver_bill_printed"
        @trades = @trades.where(:deliver_bill_printed_at.exists => true)
      end
 
    # 物流单是否已打印
    if params[:logistic_status] == "logistic_all"
    elsif params[:logistic_status] == "logistic_unprinted"
      @trades = @trades.where(:logistic_printed_at.exists => false)
    elsif params[:logistic_status] == "logistic_printed"
      @trades = @trades.where(:logistic_printed_at.exists => true)
    end

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

    if current_user.role_key == 'seller'
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
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first

    @trade.seller_id = params[:seller_id]

    if @trade.seller_id_changed?
      if @trade.seller_id
        @trade.dispatched_at = Time.now
      else
        @trade.dispatched_at = nil
      end
    end

    if params[:delivered_at] == true
      @trade.logistic_code = params[:logistic_code]
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

    unless params[:orders].blank?
      params[:orders].each do |item|
        order = @trade.orders.find item[:id]
        order.cs_memo = item[:cs_memo]
        order.color_num = item[:color_num]
        color = Color.where(num: item[:color_num]).first
          order.color_hexcode = color.try(:hexcode)
          order.color_name = color.try(:name)
      end
    end

    @trade.save!

    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end
end