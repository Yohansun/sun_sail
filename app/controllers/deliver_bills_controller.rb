# encoding: utf-8

class DeliverBillsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    offset = params[:offset] || 0
    limit = params[:limit] || 20

    if params[:trade_type]
      case params[:trade_type]
      when 'unprinted'
        @bills = @bills.where(:deliver_printed_at.exists => false)
      when 'printed'
        @bills = @bills.where(:deliver_printed_at.exists => true)
      when 'waybill_void'
        @bills = @bills.where(:deliver_bill_number.exists => false)
      when 'waybill_exist'
        @bills = @bills.where(:deliver_bill_number.exists => true)
      end
    end

    if params[:search]
      @trades = Trade.filter(current_account, current_user, params).where(:dispatched_at.ne => nil)
      trade_ids = @trades.map(&:_id)
      @bills = DeliverBill.where(:trade_id.in => trade_ids)
    else
      @bills = DeliverBill.where(account_id: current_account.id)
    end

    if params[:deliver_bill_search]
      batch_nums = params[:deliver_bill_search][:batch].split(";")
      if batch_nums[0].size == 14
        batch_nums[0] = batch_nums[0] + "0000"
      end
      if batch_nums[1].size == 14
        batch_nums[1] = batch_nums[1] + "9999"
      end
      min = batch_nums[0].to_i
      max = batch_nums[1].to_i
      @bills = @bills.where(:print_batches.elem_match => {"$and" => [{batch_num: {"$gte" => min}}, {batch_num: {"$lte" => max}}]})
    end

    if current_user.seller.present?
      ids = []

      seller = current_user.seller
      ids = seller.self_and_descendants.map(&:id) if seller

      @bills = @bills.any_in(seller_id: ids)
    end

    @bills_count = @bills.count
    @bills = @bills.limit(limit).skip(offset).order_by(:created.desc)

    if @bills_count > 0
      respond_with @trades
    else
      render json: []
    end
  end

  def show
    @bill = DeliverBill.find params[:id]
    @trade = TradeDecorator.decorate @bill.trade
    respond_with @bill
  end

  def batch_print_deliver
    if params[:ids] && params[:time]
      time = params[:time].to_time(:local)
      DeliverBill.any_in(id: params[:ids].split(',')).each do |bill|
        trade = bill.trade
        is_first_print = !trade.deliver_bill_printed_at.present?
        trade.update_attributes(deliver_bill_printed_at: time)

        bill.update_attributes(deliver_printed_at: time)
        trade.operation_logs.create(
          operated_at: time,
          operation: '打印发货单',
          operator_id: current_user.id,
          operator: current_user.name
        )

        #如果满足自动化设置条件，打印发货单后订单自动发货
        auto_settings = current_account.settings.auto_settings
        if auto_settings['auto_deliver'] && current_account.can_auto_deliver_right_now? && is_first_print
          if auto_settings["deliver_condition"] == "deliver_bill_printed_trade"
            trade.update_attributes(delivered_at: Time.now)
            trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
          end
        end
      end
    end

    render json: {isSuccess: true}
  end

  def print_deliver_bill
    @bills = DeliverBill.find(params[:ids].split(','))
    if @bills.count == 1
      print_batch_number = Time.now.to_s(:number).to_i
      @bills.first.print_batches.create(batch_num: (print_batch_number*10000+1))
    end
    respond_to do |format|
      format.xml
    end
  end

  def logistic_info
    @bill = DeliverBill.find params[:id]
    trade = @bill.trade
    xml = nil
    if trade
      logistic = Logistic.find_by_id(trade.try(:logistic_id))
      logistic ||= Logistic.find_by_id(trade.matched_logistics.select{ |e| e[2].present? }.first.try(:at, 0))
      if logistic
        xml = "/logistics/#{logistic.id}/print_flash_settings/#{logistic.print_flash_setting.id}/print_infos.xml"
      else
        xml = nil
      end
      # xml = Logistic.find_by_id(trade.try(:logistic_id)).try(:xml)
      # xml ||= trade.matched_logistics.select{ |e| e[2].present? }.first.try(:at, 2)
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
    print_batch_number = Time.now.to_s(:number).to_i
    DeliverBill.find(params[:ids]).each_with_index do |bill, index|
      bill.print_batches.create(batch_num: (print_batch_number*10000+index+1))
      trade = TradeDecorator.decorate(bill.trade)
      list << {
        name: trade.receiver_name,
        tid: trade.tid,
        batch_sequence: bill.print_batches.last.batch_num.to_s[0..-5],
        batch_index: bill.print_batches.last.batch_num.to_s[-4..-1],
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
    DeliverBill.any_in(id: params[:ids].split(',')).each do |bill|
      trade = bill.trade
      is_first_print = !trade.logistic_printed_at.present?
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

      #如果满足自动化设置条件，打印物流单后订单自动发货
      auto_settings = current_account.settings.auto_settings
      if auto_settings['auto_deliver'] && current_account.can_auto_deliver_right_now? && is_first_print
        if auto_settings["deliver_condition"] == "logistic_bill_printed_trade"
          trade.update_attributes(delivered_at: Time.now)
          trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
        end
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
        is_first_set = !trade.logistic_waybill.present?
        trade.logistic_code = logistic.try(:code)
        trade.logistic_waybill = info["logistic"].present? ? info["logistic"] : trade.tid
        trade.logistic_name = logistic.try(:name)
        trade.logistic_id = logistic.try(:id)
        trade.save
        trade.operation_logs.create(operated_at: Time.now, operation: '设置物流单号', operator_id: current_user.id, operator: current_user.name)

        #如果满足自动化设置条件，设置物流单号后订单自动发货
        auto_settings = current_account.settings.auto_settings
        if current_account.settings.auto_settings['auto_deliver'] && current_account.can_auto_deliver_right_now? && is_first_set
          if auto_settings["deliver_condition"] == "has_logistic_waybill_trade"
            trade.update_attributes(delivered_at: Time.now)
            trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
          end
        end
      end
    else
      flag = false
    end

    render json: {isSuccess: flag}
  end
end
