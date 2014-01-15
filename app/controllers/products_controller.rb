# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController

  before_filter :authorize
  before_filter :get_products, :only => [:sync_taobao_products,:confirm_sync]
  before_filter :tmp_skus, :only => [:new,:create,:add_sku,:remove_sku]

  def index
    @products = current_account.products
    if params[:info_type].present? || params[:info].present?
      if params[:info_type] == "sku_info"
        @products = @products.joins(:skus).where("properties_name like ?", "%#{params[:info]}%")
      else
        @products = @products.where("#{params[:info_type]} like ? or #{params[:info_type]} = ?", "%#{params[:info].strip}%", params[:info].strip)
      end
    end

    if params[:level_0_id].present? && params[:level_0_id] != '0'
      @products = @products.where("category_id = ?", update_category(params))
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
    params[:product][:category_id] = update_category(params)
    @product = current_account.products.new params[:product]
    @skus.each do |sku|
      @product.skus.build({:sku_id => sku.sku_id, :account_id => current_account.id}.merge(sku.attributes))
    end
    if @product.save
      sku_value = []
      @product.skus.each do |sku|
        unless sku.value == ""
          sku_value << sku.value
        end
      end
      @product.skus.create(account_id: current_account.id, product_id: @product.id, num_iid: @product.num_iid) if sku_value.size == 0
      current_user.settings.tmp_skus = []
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = current_account.products.find params[:id]
    @category_id = @product.category.try(:id)
    @skus = @product.skus
  end

  def update
    params[:product][:category_id] = update_category(params)
    @product = current_account.products.find params[:id]
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

  def confirm_import_csv
    if params[:csv] && File.exists?(params[:csv])
      Product.confirm_import_from_csv(current_account, params[:csv])
    end
    redirect_to products_path
  end

  def import_csv
    if params[:file] && params[:file].tempfile
      @csv = "#{Rails.root}/public/#{Time.now.to_i}.csv"
      FileUtils.mv params[:file].tempfile, @csv
      begin
        @products = Product.import_from_csv(current_account, @csv)
      rescue Exception => e
        Rails.logger.info e.inspect
        flash[:notice] = "上传文件有误请重新上传,只接受csv文件,可以先导出商品,按照格式修改后导入" + e.inspect
        redirect_to :back
      end
    end
  end

  def sync_taobao_products
  end

  def confirm_sync
    begin
      TaobaoProduct.transaction do
        TaobaoSku.transaction do
          @products.map(&:perform)
        end
      end
      redirect_to :action => :taobao_products
    rescue Exception => e
      render :text => e.message
    end
  end

  def fetch_category_properties
    if params[:category_id].present?
      @category = current_account.categories.find(params[:category_id])
      @category_properties = @category.category_properties.where(value_type: 2)
    end

    respond_to do |format|
      format.js
    end
  end

  def add_sku
    begin
      values = []
      params[:sku_property].each do |k,v|
        a_values = []
        v["category_property_value_id"].each do |_v|
          value = CategoryPropertyValue.find(_v).value
          a_values << value
        end
        values << a_values
      end
      values = get_values_array(values)
      values.each do |value|
        sku = OpenStruct.new({:id =>Time.now.strftime("%Y%m%d%k%M%S%L") }.merge!(params[:tmp_sku] || {}))
        sku.value = value.split(" ") * "|"
        sku.sku_properties ||= []
        hash_value = {}
        value.split(" ").each do |v|
          category_property_id = CategoryPropertyValue.find_by_value(v).category_property_id
          category_property_value_id = CategoryPropertyValue.find_by_value(v).id
          sku.sku_properties << OpenStruct.new({"category_property_value_id" => category_property_value_id}.merge(:id => category_property_id))
          hash_value.merge!(category_property_id => {"category_property_value_id"=>category_property_value_id})
        end
        sku.attributes = {"sku_properties_attributes" => hash_value}.merge!(params[:tmp_sku] || {})

        @product = current_account.products.find_by_id params[:id]

        if @product.blank?
          @skus = current_user.settings.tmp_skus += Array.wrap(sku)
        else
          Sku.create(:sku_id=>params[:tmp_sku][:sku_id],:account_id => current_account.id,:product_id => params[:id],:sku_properties_attributes => hash_value)
          @skus = @product.skus
        end
      end
    rescue Exception => e
      @error_message = e.message
      @error_message = "Sku信息不能为空" if params[:sku_property].blank?
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_sku
    @product = current_account.products.find_by_id params[:id]
    update_sku_ids = params[:update_sku_ids]
    sku_ids = params[:sku_ids]
    if params[:commit]
      if @product.blank?
        skus = []
        @current_user.settings.tmp_skus.each_with_index do |sku, index|
          sku.sku_id = update_sku_ids[index]
          skus << sku
        end
        current_user.settings.destroy :tmp_skus
        current_user.settings.tmp_skus = skus
        @skus = current_user.settings.tmp_skus
      else
        @product.skus.reject{|sku| sku.value == "默认"}.each_with_index do |sku, index|
          sku.update_attributes(sku_id: update_sku_ids[index])
        end
        @skus = @product.skus
      end
    else
      @skus.delete_if {|sku| sku_ids.include?(sku.id) }
      if @product.blank?
        current_user.settings.tmp_skus = @skus
      else
        @product.skus.where(:id => sku_ids).delete_all
        @skus = @product.skus
      end
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

  # 获取勾选商品的id
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

  # 移除去掉勾选商品的id
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
    if params[:on_sale].strip == "上架"
      @products.update_all(on_sale: false)
    elsif params[:on_sale].strip == "下架"
      @products.update_all(on_sale: true)
    end
    current_account.settings.picked_product = []
    render :nothing => true, status: 200
  end

  def taobao_products
    @native_skus = current_account.skus
    @products = current_account.taobao_products
    if params[:key] && params[:value] && params[:value] != ''
      @products = @products.where("#{params[:key]} like ? ", "%#{params[:value].strip}%")
    end
    @number = 20
    @number = params[:number] if params[:number].present?
    taobao_product_id = TaobaoSku.no_binding.with_account(current_account.id).map{|sku| sku.taobao_product_id}  if params[:has_bindings] == "未绑定 || 部分绑定"
    taobao_product_id = TaobaoSku.is_binding.with_account(current_account.id).map{|sku| sku.taobao_product_id}  if params[:has_bindings] == "已绑定"
    if params[:has_bindings].blank? || params[:has_bindings] == "全部"
      @products = @products.search(params[:search])
    else
      @products = @products.where("id in (?)",taobao_product_id).search(params[:search])
    end
    @products = @products.page(params[:page]).per(@number)

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
          SkuBinding.create(resource_id: params[:taobao_sku_id].to_i,resource_type: "TaobaoSku", sku_id: info_array[1].to_i, number: info_array[2].to_i)
        end
      end
    end
    render :nothing => true, status: 200
  end

  private

  def get_products
    begin
      @news_products = []
      @changes_products = []
      @products = []
      TradeSource.where(trade_type: "Taobao",account_id: current_account.id).each do |trade_source|
        begin
          @products << product = TaobaoProductSync.new(trade_source.id)
          product.parsing
          @news_products    += product.latest
          @changes_products += product.changed
        rescue Exception
          next
        end
      end
    rescue Exception => e
      render(:text => e.message) and return
    end
  end

  def tmp_skus
    @skus = (current_user.settings.tmp_skus ||= [])
  end

  # 多数组取第一个元素组成一个新的数组
  # 用于排列组合新添加的sku
  def get_values_array array
    return array[0] if array.size == 1
    first = array.shift
    return first.product( get_values_array(array) ).map {|x| x.flatten.join(" ") }
  end

  def update_category(params)
    if params[:level_0_id].present? && params[:level_0_id] != '0'
      i = 0; @category_id = nil
      while params["level_#{i}_id"].present? do
        @category_id = params["level_#{i}_id"]
        i += 1
      end
    end
    @category_id
  end
end
