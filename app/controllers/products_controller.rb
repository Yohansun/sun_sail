# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController

  before_filter :authorize #,:except => [:fetch_products,:pick_product,:abandon_product,:fetch_category_properties, :taobao_skus]
  before_filter :get_products,:only => [:sync_taobao_products,:confirm_sync]
  before_filter :tmp_skus, :only => [:new,:create,:add_sku,:remove_sku]

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
    @number = 20
    @number = params[:number] if params[:number].present?
    @products = @products.order("updated_at DESC").page(params[:page]).per(@number)

    respond_to do |format|
      format.xls
      format.html{
        @all_cols = current_account.settings.product_cols
        @visible_cols = current_account.settings.product_visible_cols
      }
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
    @skus.each do |sku|
      @product.skus.build({:account_id => current_account.id}.merge(sku.attributes))
    end

    if @product.save
      if params[:product]['good_type'] == '2' && params[:child_iid].present?
        @product.create_packages(params[:child_iid])
      end
      current_user.settings.tmp_skus = []
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = current_account.products.find params[:id]
    @skus = @product.skus
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
      @skus = @product.skus
      render action: :edit
    end
  end

  def destroy
    product = current_account.products.find(params[:id])
    product.destroy
    redirect_to products_path
  end

  #GET /products/sync_taobao_products
  def sync_taobao_products
  end

  #PUT /products/confirm_sync
  def confirm_sync
    TaobaoProduct.transaction do
      TaobaoSku.transaction do
        @changes_products.map(&:save!)
        @news_products.map(&:insert!)
      end
    end

    redirect_to :action => :taobao_products
  rescue Exception => e
    render :text => e.message
  end

  #GET /products/fetch_category_properties
  def fetch_category_properties
    @category = current_account.categories.find(params[:category_id])
    @category_properties = @category.category_properties

    respond_to do |format|
      format.js
    end
  end

  #POST /products/add_sku
  def add_sku
    sku = OpenStruct.new({:id =>Time.now.strftime("%Y%m%d%k%M%S%L") }.merge!(params[:tmp_sku] || {}))

    values = []
    params[:sku_property].each do |k,v|
      sku.sku_properties ||= []
      sku.sku_properties << OpenStruct.new(v.merge(:id => k))
      values << CategoryPropertyValue.find(v["category_property_value_id"]).value
    end
    sku.value = values * " | "
    sku.attributes = {"sku_properties_attributes" => params[:sku_property]}.merge!(params[:tmp_sku] || {})

    @product = current_account.products.find_by_id params[:id]

    if @product.blank?
      @skus = current_user.settings.tmp_skus += Array.wrap(sku)
    else
      Sku.create(:sku_id=>params[:tmp_sku][:sku_id],:account_id => current_account.id,:product_id => params[:id],:sku_properties_attributes => params[:sku_property])
      @skus = @product.skus
    end

  rescue Exception => e
    @error_message = e.message
    @error_message = "Sku信息不能为空" if params[:sku_property].blank?

    respond_to do |format|
      format.js
    end
  end

  #PUT /products/remove_sku
  def remove_sku
    sku_ids = params[:sku_ids]
    @skus.delete_if {|sku| sku_ids.include?(sku.id) }
    @product = current_account.products.find_by_id params[:id]

    if @product.blank?
      current_user.settings.tmp_skus = @skus
    else
      @product.skus.where(:id => sku_ids).delete_all
      @skus = @product.skus
    end

    respond_to do |format|
      format.js
    end
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
    @number = 20
    @number = params[:number] if params[:number].present?
    @products = @products.order("updated_at DESC").page(params[:page]).per(@number)

    respond_to do |format|
      format.xls
      format.html{
        @all_cols = current_account.settings.taobao_product_cols
        @visible_cols = current_account.settings.taobao_product_visible_cols
      }
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
        taobao_skus << {id: sku.id, name: sku.title}
      end
      first_bindings = @product.taobao_skus.first.sku_bindings rescue false
      first_sku_bindings = []
      if first_bindings.present?
        first_bindings.each do |binding|
          if binding.sku.present?
            first_sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
          end
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
        if binding.sku.present?
          sku_bindings << {sku_id: binding.sku_id, name: binding.sku.title, num: binding.number}
        end
      end
    end
    render json: {sku_bindings: sku_bindings}
  end

  def search_native_skus
    skus = current_account.products.where(outer_id: params[:q]).first.skus rescue []
    sku_info = []
    skus.each do |sku|
      sku_info << {id: sku.id, text: sku.title}
    end
    render json: {sku_info: sku_info}
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

  private

  require 'sync_taobao_products'
  def get_products
    products          =  CompareProduct.new(current_account)
    @news_products    = products.not_exists
    @changes_products = products.changes
  rescue Exception => e
    render :text => e.message
  end

  def tmp_skus
    @skus = (current_user.settings.tmp_skus ||= [])
  end
end
