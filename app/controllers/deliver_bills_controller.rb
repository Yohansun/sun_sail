# -*- encoding : utf-8 -*-

class DeliverBillsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    @bills = DeliverBill.all
    if params[:trade_type]
      case params[:trade_type]
      when 'unprinted'
        @bills = @bills.where(:deliver_printed_at.exists => false)
      when 'printed'
        @bills = @bills.where(:deliver_printed_at.exists => true)
      when 'logistic_unprinted'
        @bills = @bills.where(:logistic_printed_at.exists => false)
      when 'logistic_printed'
        @bills = @bills.where(:logistic_printed_at.exists => true)
      end
    end

    if params[:condition] && params[:value]
      attribute = case params[:condition]
      when 'tid'
        :tid
      when 'r_name'
        :receiver_name
      when 'r_mobile'
        :receiver_mobile
      when 's_name'
        :seller_name
      end

      if attribute
        trade_ids = Trade.where(attribute => params[:value]).map(&:id)
        @bills = @bills.any_in(trade_id: trade_ids)
      end
    end

    if current_user.has_role? :seller
      ids = []

      seller = current_user.seller
      ids = seller.self_and_descendants.map(&:id) if seller

      @bills = @bills.any_in(seller_id: ids)
    end

    respond_with @bills
  end

  def show
    @bill = DeliverBill.find params[:id]
    @trade = TradeDecorator.decorate @bill.trade
    respond_with @bill
  end

  def batch_print_deliver
    DeliverBill.any_in(_id: params[:ids]).each do |bill|
      bill.deliver_printed_at = Time.now
      bill.save
      bill.trade.operation_logs.create(
        operated_at: Time.now,
        operation: '打印发货单',
        operator_id: current_user.id,
        operator: current_user.name
      )
    end

    render json: {isSuccess: true}
  end

   def print_deliver_bill
    @bills = DeliverBill.find(params[:ids].split(','))
    respond_to do |format|
      format.xml
    end
  end

  def logistic_info
    @bill = DeliverBill.find params[:id]
    trade = @bill.trade
    xml = nil
    if trade
      xml = Logistic.find_by_id(trade.try(:logistic_id)).try(:xml)
      xml ||= trade.matched_logistics.select{ |e| e[2].present? }.first.try(:at, 2)
    end
    render text: xml
  end

  def update
    @bill = DeliverBill.find params[:id]
    trade = @bill.trade
    logistic = Logistic.find_by_id params['logistic_id']
    trade.logistic_id = logistic.id
    trade.logistic_name = logistic.name
    trade.logistic_code = logistic.code
    trade.logistic_waybill = params["logistic_waybill"]
    trade.save

    render json: @bill.to_json, status: :ok
  end

  def deliver_list
    list = []
    DeliverBill.find(params[:ids]).each do |bill|
      trade = TradeDecorator.decorate(bill.trade)
      list << {
        name: trade.receiver_name,
        tid: trade.tid,
        address: trade.receiver_full_address,
        logistic_name: trade.logistic_name || '',
        logistic_waybill: trade.logistic_waybill || ''
      }
    end

    respond_to do |format|
      format.json { render json: list }
    end
  end

  def batch_print_logistic
    logistic = Logistic.find_by_id params[:logistic]
    success = true
    DeliverBill.any_in(_id: params[:ids]).each do |bill|
      trade = bill.trade
      trade.logistic_printed_at = Time.now

      if trade.logistic_waybill.blank?
        trade.logistic_id = logistic.try(:id)
        trade.logistic_name = logistic.try(:name)
        trade.logistic_code = logistic.try(:code)
      end

      if trade.save
        bill.update_attribute(:logistic_printed_at, Time.now)
        trade.operation_logs.create(operated_at: Time.now, operation: '打印物流单', operator_id: current_user.id, operator: current_user.name)
      else
        success = false
      end
    end

    render json: {isSuccess: success}
  end

  def setup_logistics
    flag = true
    logistic = Logistic.find_by_id params[:logistic]
    if logistic && params[:data].present?
      params[:data].values.each do |info|
        trade = Trade.where(tid: info['tid']).first
        trade.logistic_code = logistic.try(:code)
        trade.logistic_waybill = info["logistic"].present? ? info["logistic"] : trade.tid
        trade.logistic_name = logistic.try(:name)
        trade.logistic_id = logistic.try(:id)
        trade.save
        trade.operation_logs.create(operated_at: Time.now, operation: '设置物流单号', operator_id: current_user.id, operator: current_user.name)
      end
    else
      flag =false
    end

    render json: {isSuccess: flag}
  end
end
