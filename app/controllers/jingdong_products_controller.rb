#encoding: utf-8
class JingdongProductsController < ApplicationController
  before_filter :authorize
  before_filter :scan_sync,:only => [:sync,:syncing]
  # GET /jingdong_products
  def index
    params[:search] ||= {}
    params[:search][params[:key].to_sym] = params[:value] if params[:key].present? && params[:value].present?
    @search = JingdongProduct.with_account(current_account.id).search(params[:search])
    pernumber = params[:number].to_i || 20
    @jingdong_products = @search.page(params[:page]).per(pernumber)
  end

  # GET /jingdong_products/1
  def show
    @product = JingdongProduct.with_account(current_account.id).find params[:id]
  end

  # GET /jingdong_products/sync
  def sync
  end

  # PUT /jingdong_products/1/syncing
  def syncing
    [@sync_skus,@sync_products].map(&:perform)
    redirect_to :action => :index
    flash[:notice] = "同步成功"
  end

  def jingdong_skus
    @product = current_account.jingdong_products.find params[:product_id]
    if @product.jingdong_skus == []
      render json: {has_skus: false}
    else
      jingdong_skus = []
      @product.jingdong_skus.each do |sku|
        jingdong_skus << {id: sku.id, name: sku.title}
      end
      first_bindings = @product.jingdong_skus.first.sku_bindings rescue false
      first_sku_bindings = []
      if first_bindings.present?
        first_bindings.each do |binding|
          if binding.sku.present?
            first_sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
          end
        end
      end
      render json: {has_skus: true, product: @product, skus: jingdong_skus, sku_bindings: first_sku_bindings}
    end
  end

  def change_jingdong_skus
    bindings = JingdongSku.find(params[:jingdong_sku_id]).sku_bindings rescue false
    sku_bindings = []
    if bindings.present?
      bindings.each do |binding|
        if binding.sku.present?
          sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
        end
      end
    end
    render json: {sku_bindings: sku_bindings}
  end

  def tie_to_native_skus
    bindings = JingdongSku.find(params[:jingdong_sku_id]).sku_bindings
    if params[:infos]
      params[:infos].each do |info|
        info_array = info.split(",")
        if info_array[0] == "need_delete"
          bindings.where(sku_id: info_array[1].to_i, number: info_array[2].to_i).delete_all
        elsif info_array[0] == "new_add"
          SkuBinding.create(resource_id: params[:jingdong_sku_id].to_i,resource_type: "JingdongSku", sku_id: info_array[1].to_i, number: info_array[2].to_i)
        end
      end
    end
    render :nothing => true, status: 200
  end

  private
  def scan_sync
    @sync_products,@sync_skus = Array.new(2) {[]}
    current_account.jingdong_sources.each do |trade_source|
      @sync_products << sync_product = JingdongProductSync.new(trade_source.id)
      sync_product.parsing
      @sync_skus += sync_sku = JingdongSkuSync.new({ware_ids: @sync_products.ware_ids, account_id: @sync_products.account_id})
      sync_sku.parsing
    end
  end
end
