#encoding: utf-8
class YihaodianProductsController < ApplicationController
  before_filter :authorize
  before_filter :products_with_account

  # GET /yihaodian_products
  def index
    params[:search] ||= {}
    params[:search][params[:key].to_sym] = params[:value] if params[:key].present? && params[:value].present?
    product_id = YihaodianSku.no_binding.with_account(current_account.id).map{|sku| sku.product_id}  if params[:has_bindings] == "未绑定 || 部分绑定"
    product_id = YihaodianSku.is_binding.with_account(current_account.id).map{|sku| sku.product_id}  if params[:has_bindings] == "已绑定"
    if params[:has_bindings].blank? || params[:has_bindings] == "全部"
      @search = @products.search(params[:search])
    else
      @search = @products.with_account(current_account.id).where("product_id in (?)",product_id).search(params[:search])
    end
    pernumber = params[:number].to_i || 20
    @products = @search.page(params[:page]).per(pernumber)
  end

  # GET /yihaodian_products/1
  def show
    @product = @products.find params[:id]
  end

  # GET /yihaodian_products/sync
  def sync
    payload_hash = SidekiqUniqueJobs::PayloadHelper.get_payload('YihaodianProductFetcher',:yihaodian_product_fetcher, [current_account.id])

    if Sidekiq.redis {|conn| conn.exists(payload_hash)}
      flash[:notice] = "已有队列正在同步中, 请稍后再试!"
      redirect_to action: :index
    else
      YihaodianProductFetcher.perform_async(current_account.id)
      flash[:notice] = "系统开始自动同步一号店商品..."
      redirect_to action: :index
    end
  end

  # GET /yihaodian_products/syncing
  def sync_history
    if !%w(YihaodianProduct YihaodianSku).include?(params[:type].to_s)
      flash[:error] = "类型错误"
      redirect_to(action: :index)
    end

    tableize = params[:type].to_s.tableize
    search = PaperTrail::Version.joins("JOIN #{tableize} on #{tableize}.id = versions.item_id and versions.item_type = '#{params[:type]}'").where("#{tableize}.account_id = #{current_account.id}").select("*,versions.created_at as created_at").order("versions.created_at desc")
    @versions = search.page(params[:page]).per(20)
  end

  def yihaodian_skus
    @product = current_account.yihaodian_products.find params[:product_id]
    if @product.yihaodian_skus == []
      render json: {has_skus: false}
    else
      yihaodian_skus = []
      @product.yihaodian_skus.each do |sku|
        yihaodian_skus << {id: sku.id, name: sku.title}
      end
      all_sku_bindings = []
      @product.yihaodian_skus.each do |sku|
        sku_bindings = sku.sku_bindings rescue false
        if sku_bindings.present?
          sku_bindings.each do |binding|
            if binding.sku.present?
              all_sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number, yihaodian_name: YihaodianSku.find(binding.resource_id).title, yihaodian_sku_id: binding.resource_id }
            end
          end
        else
          all_sku_bindings << {sku_id: false, yihaodian_name: sku.title}
        end
      end
      render json: {has_skus: true, product: @product, skus: yihaodian_skus, sku_bindings: all_sku_bindings}
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
end
