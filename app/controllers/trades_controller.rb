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
      status = params[:search_trade_status]
      if status == 'undispatched'
        @trades = @trades.where(:dispatched_at.exists => false)
        @trades = @trades.where(:status.nin => ['WAIT_BUYER_PAY', 'TRADE_CLOSED','TRADE_CANCELED','TRADE_CLOSED_BY_TAOBAO'])
      elsif status == 'unpaid'
        @trades = @trades.where(:status.in => ["WAIT_BUYER_PAY"])
      elsif status == 'undelivered'
        @trades = @trades.where("$and" => [{:dispatched_at.exists => true},{:status.in => ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]}])
      elsif status == 'delivered'
        @trades = @trades.where(:status.in => ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"])
      elsif status == 'refund'
        @trades = @trades.where(:status.in => ["TRADE_REFUNDING"])
      elsif status == 'closed'
        @trades = @trades.where(:status.in => ["TRADE_CLOSED","TRADE_CANCELED","TRADE_CLOSED_BY_TAOBAO"])
      elsif status == 'unusual_trade'
        @trades = @trades.where(:status.in => ["TRADE_NO_CREATE_PAY"])
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

    # 调色
    if params[:search_color_status] == "matched"
      @trades = @trades.where(has_color_info: true)
    elsif params[:search_color_status] == "unmatched"
      @trades = @trades.where(has_color_info: false)
    end

    #异常
    if params[:search_unusual_trade] == "undispatched"
      @trades = @trades.where("$or" => [{"$and" => [{:pay_time.lte => Time.now - 2.days},{:dispatched_at.exists => false}]},{"$and" => [{_type: "JingdongTrade"},{:created.lte => Time.now - 2.days},{:dispatched_at.exists => false}]}])
    elsif params[:search_unusual_trade] == "undelivered"
      t_t_hash = {"$and" => [{_type: "JingdongTrade"}, {:order_end_time.exists => false}]}
      j_t_hash = {"$and" => [{_type: "TaobaoTrade"}, {:consign_time.exists => false}]}
      t_p_o_hash = {"$and" => [{_type: "TaobaoPurchaseOrder"},{"$and" => [{:consign_time.exists => false}, {:delivered_at.exists => false}]}]}
      @trades = @trades.where("$and" => [{:dispatched_at.lte => Time.now - 2.days},{"$or" => [t_t_hash, j_t_hash, t_p_o_hash]}])
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
      @trades = @trades.where(has_color_info: true)
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

    if params[:seller_id].present?
      seller = Seller.find_by_id params[:seller_id]
      @trade.dispatch!(seller) if seller
    elsif params[:seller_id].nil?
      @trade.seller_id = nil
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

    unless params[:reason].blank?
      @trade.unusual_states.build(reason: params[:reason], created_at: Time.now, reporter: current_user.name)
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

    @trade.save!

    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end

  def seller_for_area
    trade = Trade.find params[:id]
    area = Area.find params[:area_id]
    seller = trade.matched_seller_with_default(area)
    respond_to do |format|
      format.json { render json: {seller_id: seller.id, seller_name: seller.name} }
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
end