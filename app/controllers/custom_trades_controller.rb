# -*- encoding : utf-8 -*-
class CustomTradesController < ApplicationController
  include MagicCalculation::PostFeeCalculation
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
      @custom_trade.change_orders(params[:taobao_orders], params[:custom_trade][:status], params[:calculate_payment], action_name)
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
    native_skus = current_account.skus.where(product_id: product_id) rescue false
    skus = []
    if native_skus.present?
      native_skus.each do |sku|
        skus << {sku_id: sku.id, name: sku.name}
      end
    end
    render json: {skus: skus}
  end

  def calculate_price
    product = current_account.products.find_by_outer_id(params['outer_id'])
    price   = product.price * params['num'].to_f
    render json: {price: price}
  end

  def calculate_payment
    area     = Area.find_by_id(params['data']['area_id'])
    logistic = current_account.logistics.find_by_id(params['data']['logistic_id'])
    raise    "#{current_account.name} 没有设置任何经销商!" if logistic.blank?
    post_fee = area_post_fee(area, logistic, params['data']['weight'].to_i)
    payment  = params['data']['price'].to_f *
               (params['data']['discount'].to_f.zero? ? 100 : params['data']['discount'].to_f) / 100 +
               params['data']['balance_fee'].to_f +
               post_fee

    render json: {payment: payment}
  end

  private

  def fetch_data
    @products = current_account.products
    @area_ids = []
  end
end