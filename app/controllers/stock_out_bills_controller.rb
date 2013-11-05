# -*- encoding : utf-8 -*-
class StockOutBillsController < ApplicationController
  before_filter :set_warehouse
  before_filter :authorize #,:except => :fetch_bils
  before_filter :find_column_settings, :only => [:sync, :check, :rollback, :lock, :unlock]
  before_filter :validate_optional_status, only: [:edit, :sync, :rollback, :lock, :unlock,:update]

  def index
    parse_params
    @bills = default_scope.desc(:checked_at)
    @search = @bills.search(params[:search])
    unchecked, checked = @search.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked
    @number = 20
    @number = params[:number].to_i if params[:number].present?
    @bills = Kaminari.paginate_array(@bills).page(params[:page]).per(@number)
    @count = @search.count

    respond_to do |format|
      format.html{
        cur_page = params[:page].to_i
        @start_no = cur_page > 0 ? (cur_page - 1) * @number + 1 : 1
        find_column_settings
      }
      format.xls
    end
  end

	def new
    @bill = default_scope.new
    @bill.bill_products.build
  end

  def create
    @bill = default_scope.new(params[:stock_out_bill])
    @bill.status = "CREATED"
    @bill.is_cash_sale = params[:is_cash_sale] if params[:is_cash_sale].present?
    @bill.website = params[:website] if params[:website].present?
    update_areas!(@bill)
    @bill.update_bill_products
    if @bill.save
      flash[:notice] = "出库单#{@bill.tid}创建成功"
      redirect_to warehouse_stock_out_bill_path(@warehouse.id,@bill.id)
    else
      #TODO 错误提示重复
      flash[:error] = (@bill.errors.full_messages.uniq + @bill.bill_products_errors).to_sentence
      render :new
    end
  end

  def edit
    @bill = default_scope.find params[:id]
    if @bill.status != "CREATED"
      flash[:error] = "只能编辑手动新增的状态为待审核的出库单."
      redirect_to(:action => "index") and return
    end
    @products = @bill.bill_products
    parse_area(@bill)
  end

  def show
    @bill = default_scope.find params[:id]
    @trade = TradeDecorator.decorate(@bill.trade) if @bill.trade
    @products = @bill.bill_products.page(params[:page])
    if @bill.private_stock_type?
      render template: "stock_bills/private_stock_type_templete"
    end
  end

  def update
    @bill = default_scope.find params[:id]
    @bill.attributes = params[:stock_out_bill]
    update_areas!(@bill)
    @bill.update_bill_products
    if @bill.save
      flash[:notice] = "出库单#{@bill.tid}更新成功!"
      redirect_to warehouse_stock_out_bill_path(@warehouse,@bill)
    else
      #TODO 错误提示重复
      flash[:error] = (@bill.errors.full_messages.uniq + @bill.bill_products_errors).to_sentence
      render :edit
    end
  end

  def sync
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.build_log(current_user,'同步')
      bill.sync
    end
    respond_to do |f|
      f.js
    end
  end

  def check
    @error_records = []
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    render(:js => "alert('不能操作状态为已出库的出库单')") and return if @operated_bills.where(status: "STOCKED").exists?
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      assert = bill.check
      if assert != true
        @error_records << bill.tid
        logger.error "[DATA-EXCEPTION #{Time.now.to_s(:db)}] 用户ID(#{current_user.id})审核出库单#{bill.tid}失败: #{assert}"
      end
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.build_log(current_user,'取消')
      bill.rollback
    end
    respond_to do |f|
      f.js
    end
  end

  def lock
    @bills = default_scope.any_in(_id: params[:bill_ids])
    failed = @bills.collect {|bill| [bill.tid,bill.lock!(current_user)]}.reject {|t,m| m == true}
    error_message = failed.collect {|a| a.join(":")}.join(";")
    @message = failed.blank? ? "出库单#{@bills.map(&:tid).join(',')}锁定成功." : "出库单#{error_message}."
    respond_to do |format|
      format.js
    end
  end

  def unlock
    @bills = default_scope.any_in(_id: params[:bill_ids])
    failed = @bills.collect {|bill| [bill.tid,bill.unlock!(current_user)]}.reject {|t,m| m == true}
    error_message = failed.collect {|a| a.join(":")}.join(';')
    @message = failed.blank? ? "出库单#{@bills.map(&:tid).join(',')}激活成功." : "出库单#{error_message}."
    respond_to do |format|
      format.js
    end
  end

  def get_bills
    type = params[:type]
    @stock_bills = default_scope.where(:_type => type,:tid => /#{params[:tid]}/,:status => "STOCKED")
    respond_to do |format|
      format.json { render partial: "partials/stock_bills.json"}
    end
  end

  def get_products
    @bill = default_scope.find_by(tid: params[:tid])
    @bill_products = @bill.bill_products
    respond_to do |format|
      format.json { render partial: "partials/bill_products.json"}
    end
  end

  private

  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id])
  end

  def update_areas!(bill)
    op_state ,op_city,op_district = bill.op_state, bill.op_city, bill.op_district
    bill.op_state    = Area.find(op_state).name     if Area.exists?(op_state)
    bill.op_city     = Area.find(op_city).name      if Area.exists?(op_city)
    bill.op_district = Area.find(op_district).name  if Area.exists?(op_district)
  end

  def parse_area(bill)
    bill.op_state     = Area.find_by_name(bill.op_state).try(:id)
    bill.op_city      = Area.find_by_name(bill.op_city).try(:id)
    bill.op_district  = Area.find_by_name(bill.op_district).try(:id)
  end

  def parse_params
    search = params[:search] ||= {}

    params[:search][:_id_in] = params[:export_ids].split(',') if params[:export_ids].present?

    op_state,op_city,op_district = params["op_state"],params["op_city"], params["op_district"]
    search  = params[:search]
    search["op_state_eq"]     = Area.find_by_id(op_state).try(:name)    if op_state.present?
    search["op_city_eq"]      = Area.find_by_id(op_city).try(:name)     if op_city.present?
    search["op_district_eq"]  = Area.find_by_id(op_district).try(:name) if op_district.present?

    if params[:bill_products_sku_id_eq].present?
      search[:bill_products_sku_id_eq] = params[:bill_products_sku_id_eq]
    end
    search[:status_eq] = params[:status] if params[:status].present?
    # search[:stock_type_not_eq] = "OVIRTUAL" if search[:stock_type_eq].blank?
    # This line is strange and confused.
  end

  def default_scope
    StockOutBill.where({account_id: current_account.id,:seller_id => @warehouse.id}.reject{|x,y| y.nil?})
  end

  def find_column_settings
    @all_cols = current_account.settings.stock_out_bill_cols
    @visible_cols = current_account.settings.stock_out_bill_visible_cols
  end

  def validate_optional_status
    private_stock_types = StockOutBill::PRIVATE_OUT_STOCK_TYPE
    hava_private_type = StockOutBill.where(:id.in => params[:bill_ids] || [params[:id]],:stock_type.in => private_stock_types.map(&:last)).exists?
    message = "不能操作类型为#{private_stock_types.map(&:first).join(',')}的出库单"
    if hava_private_type
      respond_to do |format|
        flash[:error] = message
        format.html { redirect_to(action: :index,error: message)}
        format.js   { render js: "alert('#{message}')" }
      end
      return
    end
  end
end