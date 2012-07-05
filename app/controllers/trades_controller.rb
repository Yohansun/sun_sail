class TradesController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!

  def index
    @trades = Trade.limit(50)
    respond_with @trades
  end
end
