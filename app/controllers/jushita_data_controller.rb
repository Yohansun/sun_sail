#encoding: utf-8
class JushitaDataController < ApplicationController
  layout "management"
  before_filter :authorize

  def index
    @trade_sources = TradeSource.includes(:account).page(params[:page])
  end
  
  def enable
    @trade_sources = TradeSource.where(id: params[:trade_source_ids])
    result = @trade_sources.map(&:enable_jsync).compact.uniq
    if result.all?{|r| r == true}
      flash[:notice] = "激活成功"
    else
      flash[:error] = "#{result.map(&:name)} 激活失败"
    end
    redirect_to action: :index
  end

  def lock
    @trade_sources = TradeSource.where(id: params[:trade_source_ids])
    result = @trade_sources.map(&:lock_jsync).compact.uniq
    if result.all?{|r| r == true}
      flash[:notice] = "锁定成功"
    else
      flash[:error] = "#{result.map(&:name)} 锁定失败"
    end
    redirect_to action: :index
  end
end
