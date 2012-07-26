# -*- encoding : utf-8 -*-

class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @trades = Trade

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

    if params[:search]
      @trades = @trades.where(Hash[params[:search][:option].to_sym, params[:search][:value]])
    end

    @trades = TradeDecorator.decorate(@trades.limit(200).order_by("created", "DESC"))

    respond_with @trades
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
      @trade.delivered_at = Time.now
    end

    unless params[:cs_memo].blank?
      @trade.cs_memo = params[:cs_memo].strip
    end

    unless params[:orders].blank?
      params[:orders].each do |item|
        order = @trade.orders.find item[:id]
        order.cs_memo = item[:cs_memo]
        order.color_num = item[:color_num]
      end
    end

    @trade.save

    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end
end