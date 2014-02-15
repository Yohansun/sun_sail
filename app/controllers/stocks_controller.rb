# -*- encoding : utf-8 -*-
class StocksController < ApplicationController
  before_filter :authorize
  before_filter :set_warehouse

  def index
    condition_relation = default_scoped.where(:"sellers.active" => true).includes(:seller,:product)
    condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS.slice(*params[:storage_status]).values.join(' and ')).scoped if params[:storage_status].present?
    conditions ||= {}
    conditions[:id_in] = params[:export_ids].split(',') if params[:export_ids].present?

    if params[:op_state].present?
      area_ids = Area.robot(params[:op_state],params[:op_city]).select(:id).map(&:id)
      conditions.merge!({:seller_sellers_areas_area_id_in => area_ids})
    elsif params[:op_district].present?
      conditions.merge!({:seller_sellers_areas_area_id_eq => params[:op_district]})
    end

    conditions = conditions.merge!(params[:search]) if params[:search].present?
    conditions.delete("product_id_in") if conditions["product_id_in"] && conditions["product_id_in"].join.blank?
    conditions.delete("seller_id_in") if conditions["seller_id_in"] && conditions["seller_id_in"].join.blank?
    if outer_ids=conditions.delete("product_outer_id_in")
      if !outer_ids.blank?
        outer_ids = conditions["product_outer_id_in"] = outer_ids.split(',')
      end
    end
    @search = condition_relation.search(conditions)
    @stock_products = @search.page(params[:page]).per(20)
    @hold_hash = set_hold_hash(@stock_products)

    respond_to do |format|
      format.html{
        if @warehouse.blank?
          @all_cols = current_account.settings.stock_product_all_cols
          @visible_cols = current_account.settings.stock_product_all_visible_cols
        else
          @all_cols = current_account.settings.stock_product_detail_cols
          @visible_cols = current_account.settings.stock_product_detail_visible_cols
        end
      }
      format.xls
    end
  end

  def old
    select_sql = "skus.*, products.name, products.outer_id, products.product_id, products.category_id, stock_products.*"
    @stock_products = default_scoped.joins(:product).joins(:sku).select(select_sql).order("stock_products.product_id")
    if params[:info_type].present? && params[:info].present?
      if params[:info_type] == "sku_info"
        @stock_products = @stock_products.where("skus.properties_name like ?", "%#{params[:info]}%")
      else
        @stock_products = @stock_products.where("products.#{params[:info_type]} like ?", "%#{params[:info].strip}%")
      end
    end
    if params[:category].present? && params[:category] != '0'
      @stock_products = @stock_products.where("products.category_id = ?", params[:category])
    end
    if params[:stock_state].present?
      case params[:stock_state]
      when 'safe'
        @stock_products = @stock_products.where("stock_products.activity < stock_products.safe_value")
      when 'max'
        @stock_products = @stock_products.where("stock_products.actual = stock_products.max ")
      else
        @stock_products = @stock_products.where("stock_products.actual != stock_products.max AND stock_products.activity >= stock_products.safe_value")
      end
    end

    @stock_products = @stock_products.where(" good_type != 2 OR good_type IS NULL ") if current_user.seller.present?
    @stock_products = @stock_products.page params[:page]

  end

  def safe_stock
    # condition_relation = StockProduct.where(default_search)
    # condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS[params[:storage_status]]).scoped if params[:storage_status].present?

    # params[:product_id_eq] ||= nil
    # params[:stock] = {"product_id_eq"=> params[:product_id_eq]}
    # if params[:stock].blank?
    #   @search = condition_relation.search
    # else
    #   @search = condition_relation.search(params[:stock])
    # end

    # @stock_products = @search.page params[:page]
    # @count = @search.count
    # respond_to do |format|
    #   format.html
    #   format.xls
    # end
    redirect_to "/"
  end

  def show
    @stock = default_scoped.find params[:id]
    @audits = @stock.audits.descending.page(params[:page])
  end

  def change_product_type
    @stock_products = default_scoped.joins(:product).select("products.name as product_name,stock_products.product_id as stock_product_product_id,products.product_id as product_product_id")
    @stock_products_name = @stock_products.collect {|x| { id: x.stock_product_product_id, text: x.product_name}}
    @stock_products_id = @stock_products.collect {|x| { id: x.stock_product_product_id, text: x.product_product_id}}
    data = [@stock_products_name, @stock_products_id]

    render :json => data
  end

  def edit_depot
    # @depot = current_account.sellers.first
    redirect_to "/"
  end

  def update_depot
    # @depot = current_account.sellers.where(default_search).find params[:id]

    # if @depot.update_attributes(params[:seller])
    #   redirect_to :action => "edit_depot"
    # else
    #   render :action => "edit_depot"
    # end
    redirect_to "/"
  end

  def edit_safe_stock
    value = params[:value]
    bool = false

    @stock_product = default_scoped.find params[:id]
    if @stock_product.blank?
    else
      if value =~ /\d/
        @stock_product = @stock_product.update_attribute(:safe_value, params[:value])
        if @stock_product
          bool = true
        end
      end
    end

    if bool
      result = "ok"
    else
      result = 'err'
    end

    render :text => result
  end

  #POST /warehouses/batch_update_safety_stock
  def batch_update_safety_stock
    @stock_products = default_scoped.where(:id => params[:stock_product_ids])
    safe_value = params[:value].present? ? params[:value].to_i : params[:safe_value].to_i
    @stock_products.each {|stock| stock.update_attributes!(safe_value: safe_value,audit_comment: "批量更新安全库存") }
    redirect_to({:action => :index,:warehouse_id => params[:warehouse_id]}.reject {|k,v| v.blank?})
  end

  #POST /warehouses/batch_update_actual_stock
  def batch_update_actual_stock
    if params[:stock_product_ids].is_a?(Array) && params[:stock_product_ids].present?
      if params[:stock_product_ids].size == 1
        stock_product = default_scoped.find(params[:stock_product_ids].first)
        @stock_products = default_scoped.where(:product_id => stock_product.product_id) rescue @stock_products = []
      else
        @stock_products = default_scoped.where(:id => params[:stock_product_ids])
      end

      actual = params[:value].present? ? params[:value].to_i : params[:actual].to_i
      if actual >= 0 && @stock_products.present?
        success,fails = StockProduct.batch_update_actual_stock(@stock_products,actual)
        flash[:notice] = "ID为#{success.join(',')} 更新实际库存#{actual}成功" if success.present?
        flash[:error] = "ID为#{fails.join(',')} 更新实际库存#{actual}失败" if fails.present?
      else
        flash[:error] =  "请输入大于 0 的整数"
      end
    end
    redirect_to({:action => :index,:warehouse_id => params[:warehouse_id]}.reject {|k,v| v.blank?})
  end

  def inventory
    if default_scoped.can_inventory?
      if default_scoped.inventory!
        flash[:notice] = "盘点出库单创建成功"
      else
        flash[:error] = "盘点失败,数据保存失败"
      end
    else
      flash[:error] = "系统有未出库出库单或已付款待分派订单，不能进行盘点"
    end
  rescue Exception => e
    flash[:error] = e.message
  ensure
    redirect_to :action => :index
  end

  private
  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id]) rescue false
  end
  def set_hold_hash(relation)
    hold_hash = {}
    trades = current_account.trades.where(status: 'WAIT_SELLER_SEND_GOODS', seller_id: nil, :forecast_seller_id.ne => nil)
    trades.each do |trade|
      trade.orders.each do |order|
        order.sku_bindings.each do |binding|
          sku_id = binding.sku_id
          sku = Sku.find_by_id(binding.sku_id)
          product = sku.try(:product)
          if product
            number = binding.number * order.num
            stock_product_id = (relation || current_account.stock_products).where(product_id: product.id, sku_id: sku_id, seller_id: trade.forecast_seller_id).first.id.to_s rescue nil
            if stock_product_id
              hold_hash[stock_product_id] ||= 0
              hold_hash[stock_product_id] += number
            end
          end
        end
      end
    end
    hold_hash
  end
  def default_search
    {account_id: current_account.id,seller_id: @warehouse && @warehouse.id}.reject {|k,v| v.blank?}
  end

  def default_scoped
    StockProduct.where(default_search)
  end

end
