# -*- encoding : utf-8 -*-
class StockOutBillsController < ApplicationController
  before_filter :authenticate_user!
	before_filter :fetch_bills

	def new
    @products = (current_user.settings.tmp_products ||= [])
    @bill = StockOutBill.new(account_id: current_account.id)
  end

  def create
    @bill = StockOutBill.new(params[:stock_out_bill].merge!({account_id: current_account.id}))
    bill_product_ids = params[:bill_product_ids].split(',')
    build_product(@bill,bill_product_ids)
    @bill.update_bill_products
    if @bill.save!
      update_areas!(@bill)
      current_user.settings.tmp_products = []
      redirect_to stock_in_bills_path
    else
      @products = (current_user.settings.tmp_products ||= [])
      render :new
    end
  end

  def edit
    @bill = StockOutBill.find_by(account_id: current_account.id,:id => params[:id])
    @products = @bill.bill_products
    parse_area(@bill)
  end

  def show
    @bill = StockOutBill.find_by(account_id: current_account.id,:id => params[:id])
    @products = @bill.bill_products
  end


  def update
    @bill = StockOutBill.find_by(account_id: current_account.id,:id => params[:id])
    parse_area(@bill)
    product_ids = params[:product_ids].split(',')
    @bill.update_bill_products
    if @bill.update_attributes(params[:stock_out_bill])
      update_areas!(@bill)
      @bill.bill_products.not_in(:id => product_ids).delete
      redirect_to :action => :index
    else
      render :edit
    end
  end

  def fetch_bills
    bills = StockOutBill.where(account_id: current_account.id).desc(:checked_at)
    unchecked, checked = bills.partition { |b| b.checked_at.nil? }
    @bills = unchecked + checked
    @bills = Kaminari.paginate_array(@bills).page(params[:page]).per(20)
  end

  def sync
    @operated_bills = StockOutBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.sync
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '同步')
    end
    respond_to do |f|
      f.js
    end
  end

  def check
    @operated_bills = StockOutBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.check
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '审核')
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    @operated_bills = StockOutBill.any_in(_id: params[:bill_ids])
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.rollback
      bill.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: '取消')
    end
    respond_to do |f|
      f.js
    end
  end

  def add_product
    @bill = StockInBill.find_by(account_id: current_account.id, id: params[:id]) rescue false

    if @bill.present?
      @tmp_products = @bill.bill_products
      @bill.bill_products.build(params[:product])
      @bill.update_bill_products
      @bill.save!
    else
      add_tmp_product(params[:product])
    end
    respond_to do |format|
      format.js
    end
  end

  def remove_product
    @bill = StockInBill.find_by(account_id: current_account.id, id: params[:id]) rescue false
    if @bill.present?
      @tmp_products = @bill.bill_products
      @bill.bill_products.in(:id => params[:bill_product_ids]).delete
    else
      @tmp_products = current_user.settings.tmp_products
      if params[:bill_product_ids].present?
        current_user.settings.tmp_products = @tmp_products.keep_if {|x| !params[:bill_product_ids].include?(x.id.to_s)}
      end
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def update_areas!(bill)
    op_state ,op_city,op_district = bill.op_state, bill.op_city, bill.op_district
    bill.op_state    = Area.find(op_state).name     if Area.exists?(op_state)
    bill.op_city     = Area.find(op_city).name      if Area.exists?(op_city)
    bill.op_district = Area.find(op_district).name  if Area.exists?(op_district)
    bill.save!
  end

  def build_product(bill,bill_product_ids)
    @tmp_products = current_user.settings.tmp_products.select {|x| bill_product_ids.include?(x.id.to_s)}
    @tmp_products.each {|product| bill.bill_products.build(product.marshal_dump)  }
  end

   def add_tmp_product(product)
    validate_parameter(product)
    sku_id      = product.fetch("sku_id")
    sku = Sku.find_by_id(sku_id)
    pro = sku.product
    product.merge!({:title => sku.title,:outer_id => pro.outer_id})

    @tmp_products = (current_user.settings.tmp_products ||= [])
    @tmp_products +=  [OpenStruct.new(product.merge!({:sku_id => sku_id } ))]
    current_user.settings.tmp_products = new_products(@tmp_products)
    @tmp_products = current_user.settings.tmp_products
  end

  def validate_parameter(product)
    sku_id      = product["sku_id"]
    number      = product["number"]
    total_price = product["total_price"]
    raise "sku_id 不能为空"       if sku_id.blank?
    raise "number 不能为空"       if number.blank?
    raise "total_price 不能为空"  if total_price.blank?
  end

  def parse_area(bill)
    bill.op_state     = Area.find_by_name(bill.op_state).try(:id)
    bill.op_city      = Area.find_by_name(bill.op_city).try(:id)
    bill.op_district  = Area.find_by_name(bill.op_district).try(:id)
  end

  def new_products(tmp_products)
    @new_products = []

    tmp_product_groups = tmp_products.group_by {|i| i.sku_id}
    tmp_product_groups.each do |sku_id,collections|
      product_statis = {:sku_id => sku_id, :id => sku_id}
      collections.collect do |tmp_bill_product|
        product_statis.merge!(tmp_bill_product.marshal_dump.except(:sku_id)) {|x,y,z| y.to_i + z.to_i  }
        product_statis.merge!({:price => tmp_bill_product.price,:title => tmp_bill_product.title,:outer_id => tmp_bill_product.outer_id})
      end
      @new_products += [OpenStruct.new(product_statis)]
    end
    @new_products
  end
end
