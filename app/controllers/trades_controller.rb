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

    # 按订单号筛选
    if params[:search] && !params[:search][:option].blank? && params[:search][:option] != 'null'
      @trades = @trades.where(Hash[params[:search][:option].to_sym, params[:search][:value]])
    end

    # 按时间筛选
    if params[:search_all] && !params[:search_all][:search_start_date].blank? && params[:search_all][:search_start_date] != 'null' && !params[:search_all][:search_end_date].blank? && params[:search_all][:search_end_date] != 'null'
      start_time = (params[:search_all][:search_start_date] + ' ' + params[:search_all][:search_start_time]).to_time(form = :local)
      end_time = (params[:search_all][:search_end_date] + ' ' + params[:search_all][:search_end_time]).to_time(form = :local)
      @trades = @trades.where(:created.gte => start_time, :created.lte => end_time)
    end

    # 按状态筛选
    if params[:search_all] && !params[:search_all][:status_option].blank? && params[:search_all][:status_option] != 'null'
      status_array = params[:search_all][:status_option].split(",")
      status_array = params[:search_all][:status_option].split(",")
      @trades = @trades.where(:status.in => status_array)
    end

    # 按来源筛选
    if params[:search_all] && !params[:search_all][:type_option].blank? && params[:search_all][:type_option] != 'null'
      @trades = @trades.where(_type: params[:search_all][:type_option])
    end

    # 客服有备注
    if params[:search_all] && params[:search_all][:search_cs_memo] == "true"
      @trades = @trades.where(:cs_memo.exists => true)
    end

    # 卖家有备注  ###have not been tested yet
    if params[:search_all] && params[:search_all][:search_seller_memo] == "true"
      @trades = @trades.where("$or" => [{"$and" => [{:seller_memo.exists => true}, {:seller_memo.ne => ''}]}, {:delivery_type.exists => true}, {:invoice_info.exists => true}])
    end
    
    # 客户有留言  ###have not been tested yet
    if params[:search_all] && params[:search_all][:search_buyer_message] == "true"
      @trades = @trades.where("$and" => [{:buyer_message.exists => true}, {:buyer_message.ne => ''}])
    end

    # 需要开票
    if params[:search_all] && params[:search_all][:search_invoice] == "true"
      @trades = @trades.where("$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}])
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
      @trade.status = 'WAIT_BUYER_CONFIRM_GOODS'
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

    # unless params[:invoice_date].blank?
    #   @trade.invoice_date = params[:invoice_date].strip
    # end

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
        color = Color.find_by_num item[:color_num]
        if order.color_num.present? && color.present?
          order.color_hexcode = color.hexcode
          order.color_name = color.name
        end
      end
    end

    @trade.save

    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end
end