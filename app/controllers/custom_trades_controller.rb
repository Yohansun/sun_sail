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
        SetForecastSellerWorker.perform_async(@custom_trade.id)
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
        SetForecastSellerWorker.perform_async(@custom_trade.id)
        redirect_to "/app#trades"
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def change_products
    product_id = current_account.products.find_by_outer_id(params[:outer_id]).id
    native_skus = Sku.where(product_id: product_id) rescue false
    skus = []
    if native_skus.present?
      native_skus.each do |sku|
        skus << {sku_id: sku.id, name: sku.name}
      end
    end
    render json: {skus: skus}
  end

  private

  def fetch_data
    @products = current_account.products
    @area_ids = []
  end
end