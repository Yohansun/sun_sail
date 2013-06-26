# -*- encoding : utf-8 -*-
class StockInBillsController < ApplicationController
  include StockBillsHelper
  before_filter :set_warehouse
  before_filter :default_conditions,:on => [:edit,:show,:update,:add_product,:remove_product]
  before_filter :fetch_bills,:except => :index
  before_filter :authorize,:except => :fetch_bils

  def index
    parse_params
    @bills = StockInBill.where(default_search).desc(:checked_at)
    @search = @bills.search(params[:search])
    unchecked, checked = @search.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked
    @number = 20
    @number = params[:number] if params[:number].present?
    @bills = Kaminari.paginate_array(@bills).page(params[:page]).per(@number)
    @count = @search.count

    respond_to do |format|
      format.html
      format.xls
    end
  end

	def new
    @products = (current_user.settings.tmp_products ||= [])
    @products = specified_tmp_products(@products)
    @bill = StockInBill.new(default_search)
  end

  def create
    stock_in_bills = params[:stock_in_bill].merge!(default_search)
    @bill = StockInBill.new(stock_in_bills)
    bill_product_ids = params[:bill_product_ids].split(',')
    build_product(@bill,bill_product_ids)
    @bill.update_bill_products
    if @bill.save
      update_areas!(@bill)
      tmp_products = current_user.settings.tmp_products
      tmp_products = tmp_products.reject { |x| bill_product_ids.include?(x.id.to_s) }
      current_user.settings.tmp_products = tmp_products
      redirect_to  warehouse_stock_in_bills_path(@warehouse)
    else
      @products = (current_user.settings.tmp_products ||= [])
      render :new
    end
  end

  def edit
    @bill = StockInBill.find_by(@conditions)
    @products = @bill.bill_products
    parse_area(@bill)
  end

  def show
    @bill = StockInBill.find_by(@conditions)
    @products = @bill.bill_products
  end

  def update
    @bill = StockInBill.find_by(@conditions)
    parse_area(@bill)
    bill_product_ids = params[:bill_product_ids].split(',')
    if @bill.update_attributes(params[:stock_in_bill])
      update_areas!(@bill)
      @bill.bill_products.not_in(:id => bill_product_ids).delete
      redirect_to :action => :index
    else
      render :edit
    end
  end

  def fetch_bills
    bills = StockInBill.where(default_search).desc(:checked_at)
    unchecked, checked = bills.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked
    @bills = Kaminari.paginate_array(@bills).page(params[:page]).per(20)
  end

  def sync
    @operated_bills = StockInBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      bill.sync
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '同步')
    end
    respond_to do |f|
      f.js
    end
  end

  def check
    @operated_bills = StockInBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      bill.check
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '审核')
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    @operated_bills = StockInBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      bill.rollback
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '取消')
    end
    respond_to do |f|
      f.js
    end
  end

  def add_product
    @bill = StockInBill.find_by(@conditions) rescue false

    params[:product][:real_number] = params[:product][:number] if params[:product][:real_number].blank?
    if @bill.present?
      @tmp_products = @bill.bill_products
      @bill.bill_products.build(params[:product])
      @bill.update_bill_products
      @bill.save
    else
      add_tmp_product(params[:product])
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_product
    @bill = StockInBill.find_by(@conditions) rescue false
    if @bill.present?
      @tmp_products = @bill.bill_products
      @bill.bill_products.in(:id => params[:bill_product_ids]).delete
    else
      @tmp_products = current_user.settings.tmp_products
      if params[:bill_product_ids].present?
        @tmp_products = @tmp_products.reject { |x| params[:bill_product_ids].include?(x.id.to_s) }
        current_user.settings.tmp_products = @tmp_products
      end
      @tmp_products = specified_tmp_products(@tmp_products)
    end
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
    if params[:checked_at] == "nil"
      search[:checked_at_not_eq] = nil
    elsif params[:checked_at] == "true"
      search[:checked_at_eq] = nil
    end
  end
  
  def default_search
    {account_id: current_account.id,:seller_id => @warehouse.id}
  end

  def default_conditions
    @conditions = default_search.merge({:id => params[:id]})
  end
end