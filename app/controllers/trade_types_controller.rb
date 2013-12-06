#encoding: utf-8
class TradeTypesController < ApplicationController
  layout "management"
  before_filter :authorize
  before_filter :trade_types
  before_filter :validate_key,only: [:create,:update]


  def index;end
  
  def new;end

  def create
    settings.merge!("trade_types",{params[:key] => params[:value]})
    flash[:notice] = "创建成功"
    redirect_to action: :index
  end

  def edit;end

  def update
    settings.trade_types =  trade_type.except(params[:id]).merge(params[:key] => params[:value])
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

  def trade_types
    @trade_types = (settings.trade_types ||= {})
  end

  def validate_key
    if params[:id] != params[:key] && trade_types.key?(params[:key])
      flash[:error] = "英文名已存在,请选择其他英文名!"
      render(action: :edit,id: params[:id]) and return if params[:id]
      render(action: :new) and return
    end
  end
end
