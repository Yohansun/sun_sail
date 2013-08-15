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
    
    @serial_sku = YihaodianSerialSkuSync.new({account_id: current_account.id, product_ids: @serial_product.product_ids})
    @combine_sku = YihaodianCombineSkuSync.new({account_id: current_account.id, product_ids: @combine_product.product_ids})
    @products = [@serial_product,@combine_product]
    @skus = [@serial_sku,@combine_sku]
    @products.map(&:parsing)
    @skus.map(&:parsing)
    @latest_products = @products.map(&:latest).flatten.compact
    @latest_skus = @skus.map(&:latest).flatten.compact
    @changed_products = @products.map(&:changed).flatten.compact
    @changed_skus = @skus.map(&:changed).flatten.compact
  end
end
