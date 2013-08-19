class YihaodianProductsController < ApplicationController
  before_filter :authorize
  before_filter :products_with_account
  before_filter :scan_sync,:only => [:sync,:syncing]

  # GET /yihaodian_products
  def index
    params[:search] ||= {}
    params[:search][params[:key].to_sym] = params[:value] if params[:key].present? && params[:value].present?
    @search = @products.search(params[:search])
    @products = @search.page(params[:page])
  end

  # GET /yihaodian_products/1
  def show
    @product = @products.find params[:id]
  end

  # GET /yihaodian_products/sync
  def sync
  end

  # PUT /yihaodian_products/syncing
  def syncing
    @products.map(&:perform) && @skus.map(&:perform)
    redirect_to :action => :index
  end

  def yihaodian_skus
    @product = current_account.yihaodian_products.find params[:product_id]
    if @product.yihaodian_skus == []
      render json: {has_skus: false}
    else
      yihaodian_skus = []
      @product.yihaodian_skus.each do |sku|
        yihaodian_skus << {id: sku.id, name: sku.product_cname}
      end
      first_bindings = @product.yihaodian_skus.first.sku_bindings rescue false
      first_sku_bindings = []
      if first_bindings.present?
        first_bindings.each do |binding|
          if binding.sku.present?
            first_sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
          end
        end
      end
      render json: {has_skus: true, product: @product, skus: yihaodian_skus, sku_bindings: first_sku_bindings}
    end
  end

  def change_yihaodian_skus
    bindings = YihaodianSku.find(params[:yihaodian_sku_id]).sku_bindings rescue false
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
    bindings = YihaodianSku.find(params[:yihaodian_sku_id]).sku_bindings
    if params[:infos]
      params[:infos].each do |info|
        info_array = info.split(",")
        if info_array[0] == "need_delete"
          bindings.where(sku_id: info_array[1].to_i, number: info_array[2].to_i).delete_all
        elsif info_array[0] == "new_add"
          SkuBinding.create(resource_id: params[:yihaodian_sku_id].to_i,resource_type: "YihaodianSku", sku_id: info_array[1].to_i, number: info_array[2].to_i)
        end
      end
    end
    render :nothing => true, status: 200
  end

  private
  def products_with_account
    @products = YihaodianProduct.with_account(current_account)
  end

  def scan_sync
    key = current_account.key
    # 系列产品
    @serial_product = YihaodianSerialProductSync.new(key)
    # 套餐产品
    @combine_product = YihaodianCombineProductSync.new(key)
    # 普通商品
    @general_product = YihaodianGeneralProductSync.new(key)

    @products = [@serial_product,@combine_product,@general_product]

    @products.map(&:parsing)

    @serial_sku = YihaodianSerialSkuSync.new({account_id: current_account.id, product_ids: @serial_product.product_ids})
    @combine_sku = YihaodianCombineSkuSync.new({account_id: current_account.id, product_ids: @combine_product.product_ids})
    @skus = [@serial_sku,@combine_sku]
    @skus.map(&:parsing)
    @latest_products = @products.map(&:latest).flatten.compact
    @latest_skus = @skus.map(&:latest).flatten.compact
    @changed_products = @products.map(&:changed).flatten.compact
    @changed_skus = @skus.map(&:changed).flatten.compact
  end
end
