# -*- encoding : utf-8 -*-
class StockInBillsController < ApplicationController
  before_filter :authorize
  before_filter :set_warehouse
  before_filter :find_column_settings, :only => [:sync, :check, :rollback, :lock, :unlock,:confirm_stock,:confirm_sync,:confirm_cancle,:refuse_cancle]
  before_filter :validate_optional_status, :only => [:edit,:sync, :rollback, :update]

  def index
    parse_params
    @search = default_scope.search(params[:search]).desc(:created_at)

    @bills = @search.page(params[:page]).per(params[:number])
    @count = @bills.count

    respond_to do |format|
      format.html{
        cur_page = params[:page].to_i
        @start_no = cur_page > 0 ? (cur_page - 1) * (params[:number] || @bills.default_per_page).to_i + 1 : 1
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
    @bill = default_scope.new(params[:stock_in_bill])
    @bill.status = "CREATED"
    update_areas!(@bill)
    @bill.update_bill_products
    if @bill.save
      flash[:notice] = "入库单#{@bill.tid}创建成功"
      redirect_to  warehouse_stock_in_bill_path(@warehouse.id,@bill.id)
    else
      #TODO 错误提示重复
      flash[:error] = (@bill.errors.full_messages.uniq + @bill.bill_products_errors).to_sentence
      render :new
    end
  end

  def edit
    @bill = default_scope.find params[:id]
    if @bill.status != "CREATED"
      flash[:error] = "只能编辑手动新增的状态为待审核的入库单."
      redirect_to(:action => "index") and return
    end
    @products = @bill.bill_products
    parse_area(@bill)
  end

  def show
    @bill = default_scope.find params[:id]
    @products = @bill.bill_products.page(params[:page])
    if @bill.private_stock_type?
      render template: "stock_bills/private_stock_type_templete"
    end
  end

  def update
    @bill = default_scope.find params[:id]
    @bill.attributes = params[:stock_in_bill]
    update_areas!(@bill)
    @bill.update_bill_products
    if @bill.save
      flash[:notice] = "入库单#{@bill.tid}更新成功!"
      redirect_to warehouse_stock_in_bill_path(@warehouse.id,@bill.id)
    else
      #TODO 错误提示重复
      flash[:error] = (@bill.errors.full_messages.uniq + @bill.bill_products_errors).to_sentence
      render :edit
    end
  end
  
  def confirm_sync
    @bills = default_scope.any_in(_id: params[:bill_ids])
    @bills.each do |bill|
      bill.confirm_sync
    end

    respond_to do |format|
      format.js
    end
  end

  def confirm_stock
    @bills = default_scope.any_in(_id: params[:bill_ids])
    @bills.each do |bill|
      bill.confirm_stock
    end

    respond_to do |format|
      format.js
    end
  end

  # 确认撤销
  def confirm_cancle
    @bills = default_scope.any_in(_id: params[:bill_ids])
    @errors = @bills.reject { |bill| bill.confirm_cancle }.map(&:tid)

    respond_to do |format|
      format.js
    end
  end

  # 拒绝撤销
  def refuse_cancle
    @bills = default_scope.any_in(_id: params[:bill_ids])
    @errors = @bills.reject { |bill| bill.refuse_cancle }.map(&:tid)

    respond_to do |format|
      format.js
    end
  end

  def sync
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      bill.build_log(current_user,'同步')
      bill.sync
    end
    respond_to do |f|
      f.js
    end
  end

  def check
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    render(:js => "alert('不能操作状态为已入库的入库单')") and return if @operated_bills.where(status: "STOCKED").exists?
    @operated_bills.each do |bill|
      bill.build_log(current_user,'审核')
      bill.check
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    @operated_bills = default_scope.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      bill.build_log(current_user,'取消')
      bill.rollback
    end
    respond_to do |f|
      f.js
    end
  end

  def lock
    @bills = default_scope.any_in(_id: params[:bill_ids])
    failed = @bills.collect {|bill| bill.build_log(current_user,'锁定') &&  [bill.tid,bill.lock!(current_user)]}.reject {|t,m| m == true}
    error_message = failed.collect {|a| a.join(":")}.join(";")
    @message = failed.blank? ? "入库单#{@bills.map(&:tid).join(',')}锁定成功." : "入库单#{error_message}."
    respond_to do |format|
      format.js
    end
  end

  def unlock
    @bills = default_scope.any_in(_id: params[:bill_ids])
    failed = @bills.collect {|bill| bill.build_log(current_user,'激活') && [bill.tid,bill.unlock!(current_user)]}.reject {|t,m| m == true}
    error_message = failed.collect {|a| a.join(":")}.join(';')
    @message = failed.blank? ? "入库单#{@bills.map(&:tid).join(',')}激活成功." : "入库单#{error_message}."
    respond_to do |format|
      format.js
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
    bill.save
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
    search["op_state_eq"]     = Area.find_by_id(op_state).try(:name)    if op_state.present?
    search["op_city_eq"]      = Area.find_by_id(op_city).try(:name)     if op_city.present?
    search["op_district_eq"]  = Area.find_by_id(op_district).try(:name) if op_district.present?

    if params[:bill_products_sku_id_eq].present?
      search[:bill_products_sku_id_eq] = params[:bill_products_sku_id_eq]
    end
    search[:status_eq] = params[:status] if params[:status].present?
    search[:stock_type_not_eq] = "IVIRTUAL" if search[:stock_type_eq].blank?
  end

  def default_scope
    StockInBill.where({account_id: current_account.id,:seller_id => @warehouse.id}.reject{|x,y| y.nil?})
  end

  def find_column_settings
    @all_cols = current_account.settings.stock_in_bill_cols
    @visible_cols = current_account.settings.stock_in_bill_visible_cols
  end

  def validate_optional_status
    private_stock_types = StockInBill::PRIVATE_IN_STOCK_TYPE
    hava_private_type = StockInBill.where(:id.in => params[:bill_ids] || [params[:id]]).any_of({:operation => "locked"},{:stock_type.in => private_stock_types.map(&:last)}).exists?
    message = "不能操作类型为#{private_stock_types.map(&:first).join(',')}和状态为已锁定的入库单"
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