# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :xls

  def index
    @trades = Trade
    seller = current_user.seller

    if current_user.role_key == 'seller'
      if seller
        @trades = Trade.where(seller_id: seller.id)
      else
        render json: []
        return
      end
    elsif current_user.role_key == 'interface'
      if seller
        @trades = Trade.where(:seller_id.in => seller.child_ids)
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

    ## 导航栏筛选

    # 订单
    if !params[:search_trade_status].blank? && params[:search_trade_status] != 'null'
      if params[:search_trade_status] == 'undispatched_trade'
        @trades = @trades.where(:dispatched_at.exists => false)
      elsif params[:search_trade_status] == 'unusual_trade'
        #异常订单
      else
        status_array = params[:search_trade_status].split(",")
        @trades = @trades.where(:status.in => status_array)
      end
    end

    # 出货单
    # 出货单是否已打印
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


    ## 简单筛选
    if params[:search] && !params[:search][:option].blank? && params[:search][:option] != 'null' && params[:search][:option] != 'null' && !params[:search][:option].blank?
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

    # 按状态筛选
    if params[:search_all] && params[:search_all][:status_option].present?
        status_array = params[:search_all][:status_option].split(",")
        @trades = @trades.where(:status.in => status_array)
    end

    # 按来源筛选
    if params[:search_all] && params[:search_all][:type_option].present?
      @trades = @trades.where(_type: params[:search_all][:type_option])
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

    # 高级搜索$or,$and集中筛选
    if (params[:search_all] && (params[:search_all][:search_invoice] == "true" || params[:search_all][:search_seller_memo] == "true" || params[:search_all][:search_buyer_message] == "true")) || (params[:search] && (params[:search][:option] == 'receiver_name' || params[:search][:option] == 'receiver_mobile'))
      @trades = @trades.where("$and" => [receiver_name_hash, receiver_mobile_hash, seller_memo_hash, buyer_message_hash, invoice_all_hash].compact)
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
        item[:color_num].each_with_index do |num, index|
          order.color_num[index] = num
          color = Color.find_by_num num
            order.color_hexcode[index] = color.try(:hexcode)
            order.color_name[index] = color.try(:name)
        end
      end
    end

    @trade.save!

    Rails.logger.info @trade.orders.inspect

    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end
end