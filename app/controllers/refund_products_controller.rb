#encoding: utf-8
class RefundProductsController < ApplicationController
  before_filter :authorize
  before_filter :set_warehouse
  before_filter :edit_role,:only => [:edit,:update]

  # /warehouses/1/refund_products
  def index
    params[:search] ||= {}
    conditions = params[:search].merge({:id_in => params[:refund_product_ids]})
    @search = default_scope.search(conditions)

    @refund_products = @search.page(params[:page]).per(params[:number])
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def new
    @refund_product = default_scope.new
    @refund_product.refund_orders.build
  end

  def show
    @refund_product = default_scope.find(params[:id])
  end

  def edit
  end

  def create
    @refund_product = default_scope.new(params[:refund_product])
    if @refund_product.save
      flash[:notice] = "退货单#{@refund_product.refund_id}创建成功"
      redirect_to  warehouse_refund_product_path(@warehouse.id,@refund_product.id)
    else
      #TODO 错误提示重复
      flash[:error] = (@refund_product.errors.full_messages.uniq).to_sentence
      render :new
    end
  end

  def update
    if @refund_product.update_attributes(params[:refund_product])
      flash[:notice] = "退货单#{@refund_product.refund_id}更新成功"
      redirect_to  warehouse_refund_product_path(@warehouse.id,@refund_product.id)
    else
      #TODO 错误提示重复
      flash[:error] = (@refund_product.errors.full_messages).to_sentence
      render :edit
    end
  end

  def sync
    @operated_bills = default_scope.find params[:refund_product_ids].to_a
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.sync
    end
    respond_to do |f|
      f.js
    end
  end

  def check
    @operated_bills = default_scope.find params[:refund_product_ids].to_a
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.check
    end
    respond_to do |f|
      f.js
    end
  end

  def rollback
    @operated_bills = default_scope.find params[:refund_product_ids].to_a
    @operated_bills.each do |bill|
      #PUT INTO QUEUE LATER
      bill.rollback
    end
    respond_to do |f|
      f.js
    end
  end

  def locking
    @refund_products = default_scope.find params[:refund_product_ids].to_a
    faileds  = @refund_products.collect {|refund_product| refund_product.tid if !refund_product.locking}.compact

    @message = faileds.blank? ? "退货单#{@refund_products.map(&:refund_id).join(',')}锁定成功." : "退货单#{faileds.join(',')}锁定失败."
    respond_to do |format|
      format.js
    end
  end

  def enable
    @refund_products = default_scope.find params[:refund_product_ids].to_a
    faileds = @refund_products.collect {|refund_product| refund_product.tid if !refund_product.enable }.compact

    @message = faileds.blank? ? "退货订单#{@refund_products.map(&:refund_id).join(',')}激活成功." : "退货订单#{faileds.join(',')}."
    respond_to do |format|
      format.js
    end
  end

  def refund_fetch
    @taobao_refunds = RefundProductTaobaoSync.new(current_account.key)
    @taobao_refunds.parsing
    @taobao_refunds = @taobao_refunds.latest
  rescue Exception => e
    throw_exception(e)
    flash[:error] = e.message
  ensure
    redirect_to(:action => :index) if !e.nil?
  end

  def refund_save
    @taobao_refunds = RefundProductTaobaoSync.new(current_account.key)
    @taobao_refunds.parsing
    @taobao_refunds.perform(:latest)
    if @taobao_refunds.latest.any?{|x| x.valid?}
      flash[:notice] = "保存成功!"
    else
      error_records = @taobao_refunds.latest.reject {|x| x.valid?}
      flash[:error] = "保存失败!" << error_records.collect {|x| x.errors.full_messages}.join(',')
    end

  rescue Exception => e
    throw_exception(e)
    flash[:error] = e.message
  ensure
    redirect_to :action => :index
  end

  private
  def default_conditions
    {seller_id: @warehouse.id}
  end

  def set_warehouse
    @warehouse = Seller.find_by_id(params[:warehouse_id])
  end

  def default_scope
    conditions = default_conditions.reject {|k,v| v.blank?}
    RefundProduct.with_account(current_account.id).where(conditions)
  end

  def update_areas(bill)
    op_state ,op_city,op_district = bill.state_id, bill.city_id, bill.district_id
    bill.state_id    = Area.find(op_state).name     if Area.exists?(op_state)
    bill.city_id     = Area.find(op_city).name      if Area.exists?(op_city)
    bill.district_id = Area.find(op_district).name  if Area.exists?(op_district)
  end
  
  def edit_role
    if default_scope.can_edit.exists?(params[:id])
      @refund_product = default_scope.find params[:id]
    else
      flash[:error] = "只能编辑状态为 待审核,已审核待同步,已撤销同步的退货单!"
      redirect_to :action => :index
      return
    end
  end
  
  def throw_exception(e)
    BacktraceMailer.background_exception_notification(e,{data: {key: current_account.key}})
  end
end