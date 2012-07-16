class TradesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @trades = TradeDecorator.decorate(Trade.limit(50).order_by("created", "DESC"))
    Rails.logger.debug @trades.inspect
    respond_with @trades
  end
end