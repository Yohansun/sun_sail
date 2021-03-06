# -*- encoding : utf-8 -*-
class StockInBillsController < StockBillsController
  skip_before_filter :fetch_bills
  before_filter :find_column_settings, :only => [:sync, :check, :rollback, :lock, :unlock,:confirm_stock,:confirm_sync,:confirm_cancle,:refuse_cancle]
  before_filter :validate_optional_status, :only => [:edit,:sync, :rollback, :update]

  def index
    parse_params
    params[:search][:operation_logs_operation_eq] = '入库' if params[:search] && (params[:search][:operation_logs_operated_at_lte].present? || params[:search][:operation_logs_operated_at_gte].present?)
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
    if params[:stock_in_bill][:stock_type] == "ICP"
      if params[:property].blank?
        @bill = default_scope.new(params[:stock_in_bill])
        flash.now[:error] = "成品入库必须填写商品属性"
        render :new and return false
      end
      product = params[:stock_in_bill][:bill_products_attributes]["0"]
      if product["real_number"].to_i.zero?
        @bill = default_scope.new(params[:stock_in_bill])
        flash.now[:error] = "成品入库实际入库不能为0"
        render :new and return false
      else
        number = product["real_number"].to_i
        product['number'] = 1
        product['real_number'] = 1
        number.times do
          @bill = default_scope.new(params[:stock_in_bill])
          @bill.status = "CREATED"
          update_areas!(@bill)
          @bill.update_bill_products
          @bill.update_property_memo(params[:property], product["sku_id"], current_account)
          @bill.save
        end
      end
    else
      @bill = default_scope.new(params[:stock_in_bill])
      @bill.status = "CREATED"
      update_areas!(@bill)
      @bill.update_bill_products
    end
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
    if @bill.stock_type_icp?
      if params[:property].blank?
        flash.now[:error] = "成品入库必须填写商品属性"
        render :edit and return false
      end
      product = params[:stock_in_bill][:bill_products_attributes]["0"]
      @bill.update_property_memo(params[:property], product["sku_id"], current_account)
    end
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

  def fetch_category_properties
    @category_properties = current_account.skus.find_by_id(params[:sku_id]).try(:product).try(:category).try(:category_properties)
    @property_values = default_scope.find(params[:id]).bill_property_memo.property_values rescue nil
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

  def stock_type
    "入库单"
  end
end