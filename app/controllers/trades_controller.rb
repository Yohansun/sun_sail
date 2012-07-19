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
end