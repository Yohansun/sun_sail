#encoding: utf-8
class TradeTypesController < ApplicationController
  layout "management"
  before_filter :authorize

  def index
    @trade_types = trade_type
  end
  
  def new
  end

  def create
    settings.merge!("trade_types",{params[:key] => params[:value]})
    flash[:notice] = "创建成功"
    redirect_to action: :index
  end

  def edit
    @trade_types = trade_type
  end

  def update
    key = params[:id] == params[:key] ? params[:id] : params[:key]
    settings.merge!("trade_types",{ key => params[:value] })
    flash[:notice] = "更新成功"
    redirect_to action: :index
  end

  def destroy
    settings.trade_types = trade_type.stringify_keys.except(*params[:keys])
    flash[:notice] = "删除成功"
    redirect_to action: :index
  end

  private
  def settings
    current_account.settings
  end

  def trade_type
    @trade_type = (settings.trade_types ||= {})
  end
end
