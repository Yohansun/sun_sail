# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController
  before_filter :authorize,:except => :fetch_products

  def index
    @products = current_account.products
    if params[:info_type].present? || params[:info].present?
      if params[:info_type] == "sku_info"
        @products = @products.joins(:skus).where("properties_name like ?", "%#{params[:info]}%")
      else
        @products = @products.where("BINARY #{params[:info_type]} like ? or #{params[:info_type]} = ?", "%#{params[:info].strip}%", params[:info].strip)
      end
    end
    if params[:category_id].present? && params[:category_id] != '0'
      @products = @products.where("category_id = ?", params[:category_id])
    end

    if params[:on_sale].present?
      if params[:on_sale] == "on"
        @products = @products.where("on_sale = ?", true)
      elsif params[:on_sale] == "off"
        @products = @products.where("on_sale = ?", false)
      end
    end

    @searched_products = @products

    @products = @products.order("updated_at DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.xls
      format.html
    end
  end

  def show
    @product = current_account.products.find params[:id]
  end

  def new
    @product = current_account.products.new
  end

  def create
    @product = current_account.products.new params[:product]
    if @product.save
      if params[:product]['good_type'] == '2' && params[:child_iid].present?
        @product.create_packages(params[:child_iid])
      end
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = current_account.products.find params[:id]
  end

  def update
    @product = current_account.products.find params[:id]

    if params[:product]['good_type'] == '2' && params[:child_iid].present?
      @product.packages.delete_all
      @product.create_packages(params[:child_iid])
    end

    if @product.update_attributes(params[:product])
      redirect_to products_path
    else
      render action: :edit
    end
  end

  def destroy
    product = current_account.products.find(params[:id])
    product.destroy
    redirect_to products_path
  end

  def fetch_products
    @products = current_account.products.where(category_id: params[:category_id])
    respond_to do |format|
      format.js
    end
  end

  def pick_product
    picked_product = (current_account.settings.picked_product == nil ? [] : current_account.settings.picked_product)
    if params[:product_id]
      picked_product.push(params[:product_id])
    elsif params[:product_ids]
      picked_product.push(params[:product_ids])
      picked_product = picked_product.flatten.uniq
    end
    current_account.settings.picked_product = picked_product
    render :nothing => true, status: 200
  end

  def abandon_product
    picked_product = current_account.settings.picked_product
    if params[:product_id]
      picked_product.delete(params[:product_id])
    elsif params[:product_ids]
      params[:product_ids].each{|product_id| picked_product.delete(product_id)}
    end
    current_account.settings.picked_product = picked_product
    render :nothing => true, status: 200
  end

  def export_products
    @products = current_account.products.where("id in (?)", current_account.settings.picked_product)
    current_account.settings.picked_product = []
    respond_to do |format|
      format.xls
    end
  end

  def update_on_sale
    @products = current_account.products.where("id in (?)", current_account.settings.picked_product)
    if params[:on_sale] == "上架"
      @products.update_all(on_sale: false)
    elsif params[:on_sale] == "下架"
      @products.update_all(on_sale: true)
    end
    current_account.settings.picked_product = []
    render :nothing => true, status: 200
  end

  def taobao_products
    @native_skus = current_account.skus
    @products = current_account.taobao_products
    if params[:key] && params[:value] && params[:value] != ''
      @products = @products.where("BINARY #{params[:key]} like ? ", "%#{params[:value].strip}%")
    end
    @products = @products.order("updated_at DESC").page(params[:page]).per(40)

    respond_to do |format|
      format.xls
      format.html
    end
  end

  def taobao_product
    @product = current_account.taobao_products.find params[:id]
  end

  def taobao_skus
    @product = current_account.taobao_products.find params[:product_id]
    if @product.taobao_skus == []
      render json: {has_skus: false}
    else
      taobao_skus = []
      @product.taobao_skus.each do |sku|
        taobao_skus << {id: sku.id, name: sku.name}
      end
      first_bindings = @product.taobao_skus.first.sku_bindings rescue false
      first_sku_bindings = []
      if first_bindings.present?
        first_bindings.each do |binding|
          first_sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
        end
      end
      render json: {has_skus: true, product: @product, skus: taobao_skus, sku_bindings: first_sku_bindings}
    end
  end

  def change_taobao_skus
    bindings = TaobaoSku.find(params[:taobao_sku_id]).sku_bindings rescue false
    sku_bindings = []
    if bindings.present?
      bindings.each do |binding|
        sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
      end
    end
    render json: {sku_bindings: sku_bindings}
  end

  def tie_to_native_skus
    bindings = TaobaoSku.find(params[:taobao_sku_id]).sku_bindings
    if params[:infos]
      params[:infos].each do |info|
        info_array = info.split(",")
        if info_array[0] == "need_delete"
          bindings.where(sku_id: info_array[1].to_i, number: info_array[2].to_i).delete_all
        elsif info_array[0] == "new_add"
          SkuBinding.create(taobao_sku_id: params[:taobao_sku_id].to_i, sku_id: info_array[1].to_i, number: info_array[2].to_i)
        end
      end
    end
    render :nothing => true, status: 200
  end
end
