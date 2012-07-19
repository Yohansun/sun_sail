class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @trades = TradeDecorator.decorate(Trade.limit(100).order_by("created", "DESC"))
    respond_with @trades
  end

  def show
    @trade = TradeDecorator.decorate(Trade.where(_id: params[:id]).first)
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first
    @trade.seller_id = params[:seller_id]
    @trade.save
    @trade = TradeDecorator.decorate(@trade)
    respond_with(@trade) do |format|
      format.json { render :show }
    end
  end
end