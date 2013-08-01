#encoding: utf-8
class JingdongProductsController < ApplicationController
  before_filter :authorize
  # GET /products/jingdong_products
  def index
    @search = JingdongProduct.with_account(current_account.id).search(params[:search])
    @jingdong_products = @search.page(params[:page])
  end

  # GET /jingdong_products/1
  def show
    @product = JingdongProduct.with_account(current_account.id).find params[:id]
  end

  # GET /products/jingdong_products/sync
  def sync
    @sync_products = JingdongProductSync.new(current_account.key)
    @sync_products.parsing
    @sync_skus = JingdongSkuSync.new(@sync_products.ware_ids)
    @sync_skus.parsing
  end

  # PUT /products/jingdong_products/1/syncing
  def syncing
    @sync_products = JingdongProductSync.new(current_account.key)
    @sync_products.parsing
    @sync_skus = JingdongSkuSync.new(@sync_products.ware_ids)
    @sync_skus.parsing
    [@sync_skus,@sync_products].map(&:perform)
    redirect_to :action => :index
    flash[:notice] = "同步成功"
  end
end
