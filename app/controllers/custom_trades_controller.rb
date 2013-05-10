# -*- encoding : utf-8 -*-
class CustomTradesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_data

  def new
    @custom_trade = CustomTrade.new
  end

  def create
    @custom_trade = CustomTrade.make_new_trade(params[:custom_trade], current_account, current_user)
    if params[:taobao_orders]
      @custom_trade.change_orders(params[:taobao_orders], params[:custom_trade][:status], action_name)
      if @custom_trade.save
        redirect_to "/app#trades"
      else
        render :new
      end
    else
      render :new
    end
  end

  def edit
    @custom_trade = CustomTrade.find(params[:id])
    @area_ids = @custom_trade.find_area_ids
  end

  def update
    @custom_trade = CustomTrade.find(params[:id])
    @custom_trade.change_params(params[:custom_trade])
    if params[:taobao_orders]
      @custom_trade.change_orders(params[:taobao_orders], params[:custom_trade][:status], action_name)
      if @custom_trade.save
        redirect_to "/app#trades"
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def change_taobao_products
    taobao_skus = TaobaoSku.where(num_iid: params[:num_iid].to_i) rescue false
    skus = []
    if taobao_skus.present?
      taobao_skus.each do |sku|
        skus << {sku_id: sku.sku_id, name: sku.name}
      end
    end
    render json: {taobao_skus: skus}
  end

  private

  def fetch_data
    @taobao_products = current_account.taobao_products
    @area_ids = []
  end
end