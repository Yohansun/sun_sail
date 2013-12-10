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
    settings.trade_types =  @trade_types.except(params[:id]).merge(params[:key] => params[:value])
    flash[:notice] = "更新成功"
    redirect_to action: :index
  end

  def destroy
    settings.trade_types = @trade_types.stringify_keys.except(*params[:keys])
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
    # 验证key的唯一性
    flash.now[:error] = "英文名已存在,请选择其他的英文名!" if params[:id] != params[:key] && trade_types.key?(params[:key])
    flash.now[:error] = "参数不能为数字" if params[:key].to_i > 0 || params[:value].to_i > 0
    flash.now[:error] = "中文名已存在,请选择其他的中文名!" if trade_types[params[:id]] != params[:value] && trade_types.values.include?(params[:value])
    if flash[:error]
      render(action: :edit,id: params[:id]) and return if params[:id]
      render(action: :new) and return
    end
  end
end
