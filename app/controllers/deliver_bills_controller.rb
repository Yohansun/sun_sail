# encoding: utf-8

class DeliverBillsController < ApplicationController
  respond_to :json

  def index
    if params[:batch_option] == "true"
      @bills = DeliverBill.where(:_id.in => params[:ids])
    else
      @bills = DeliverBill.where(account_id: current_account.id)
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

      if params[:search_id].present?
        trade_search = TradeSearch.find(params["search_id"]) rescue trade_search = nil
        if trade_search.present? && trade_search.search_hash.present?
          params[:search] = trade_search.search_hash
        end
      end

      if params[:search]
        @trades = Trade.filter(current_account, current_user, params).where(:dispatched_at.ne => nil)
        trade_ids = @trades.map(&:_id)
        @bills = DeliverBill.where(:trade_id.in => trade_ids)
      end

      if params[:deliver_bill_search]
        batch_nums = params[:deliver_bill_search][:batch].split(";")
        if batch_nums[0].size <= 14
          batch_nums[0] = batch_nums[0] + "0000"
        end
        if batch_nums[1].size <= 14
          batch_nums[1] = batch_nums[1] + "9999"
        end
        min = batch_nums[0].to_i
        max = batch_nums[1].to_i
        @bills = @bills.where(:print_batches.elem_match => {"$and" => [{serial_num: {"$gte" => min}}, {serial_num: {"$lte" => max}}]})
      end

      if current_user.seller.present?
        ids = []
        seller = current_user.seller
        ids = seller.self_and_descendants.map(&:id) if seller
        @bills = @bills.any_in(seller_id: ids)
      end
    end
    @bills_count = @bills.count
    @bills = @bills.limit(limit).skip(offset).order_by(:created.desc)

    if @bills_count > 0
      respond_with @bills
    else
      render json: []
    end
  end

  def show
    @bill = DeliverBill.find params[:id]
    @trade = TradeDecorator.decorate @bill.trade
    respond_with @bill
  end

  #PUT /deliver_bills/1/split_invoice
  def split_invoice
    @bill = DeliverBill.find params[:id]
    @bill.split_invoice(params[:split_invoice_id])
    redirect_to "/app#deliver_bills/deliver_bills-all"
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
        if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "deliver_bill_printed_trade" && is_first_print
          trade.auto_deliver!
        end
      end
    end

    render json: {isSuccess: true}
  end

  def print_deliver_bill
    @bills = DeliverBill.find(params[:ids].split(','))
    if @bills.count == 1
      print_time = Time.now.to_s(:number).to_i - 2*10**13
      @bills.first.print_batches.create(batch_num: print_time, serial_num: (print_time*10000+1))
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
      logistic = current_account.logistics.find_by_id(trade.try(:logistic_id))
      logistic ||= current_account.logistics.find_by_id(trade.matched_logistics.select{ |e| e[2].present? }.first.try(:at, 0))
      if logistic
        xml = "/logistics/#{logistic.id}/print_flash_settings/#{logistic.print_flash_setting.id}/print_infos.xml"
      else
        xml = nil
      end
    end
    render text: xml
  end

  def update
    if params[:setup_logistic] == true
      @bill = DeliverBill.find params[:id]
      trade = @bill.trade
      is_first_set = !trade.logistic_waybill.present?
      logistic = current_account.logistics.find_by_id params[:logistic_id]
      trade.logistic_id = logistic.try(:id)
      trade.logistic_name = logistic.try(:name)
      trade.logistic_code = logistic.try(:code)
      trade.service_logistic_id = params[:service_logistic_id]
      trade.logistic_waybill = params[:logistic_waybill].present? ? params[:logistic_waybill] : @trade.tid
    end
    trade.save!

    # 如果满足自动化设置条件，设置物流单号后订单自动发货
    auto_settings = current_account.settings.auto_settings
    if current_account.settings.auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "has_logistic_waybill_trade" && is_first_set
      trade.auto_deliver!
    end

    render json: @bill.to_json, status: :ok
  end

  def deliver_list
    list = []
    print_time = Time.now.to_s(:number).to_i - 2*10**13
    DeliverBill.find(params[:ids]).each_with_index do |bill, index|
      trade = TradeDecorator.decorate(bill.trade)
      bill.print_batches.create(batch_num: print_time, serial_num: (print_time*10000+index+1))
      list << {
        name: trade.receiver_name,
        tid: trade.tid,
        batch_num: print_time,
        serial_num: bill.print_batches.last.serial_num.to_s[-4..-1],
        address: trade.receiver_full_address,
        logistic_name: trade.logistic_name || '',
        logistic_waybill: trade.logistic_waybill || ''
      }
    end
    respond_to do |format|
      format.json { render json: list }
    end
  end

  def logistic_waybill_list
    list = []
    has_wrong_trade = false
    DeliverBill.find(params[:ids]).each do |bill|
      trade = TradeDecorator.decorate(bill.trade)
      if trade.delivered_at.present?
        has_wrong_trade = true
        break
      else
        list << {
          name: trade.receiver_name,
          tid: trade.tid,
          type: trade._type,
          batch_num: (bill.print_batches.last != nil ? bill.print_batches.last.batch_num : "无批次号"),
          serial_num: (bill.print_batches.last != nil ? bill.print_batches.last.serial_num.to_s[-4..-1] : "无流水号"),
          address: trade.receiver_full_address,
          logistic_name: trade.logistic_name || '',
          logistic_waybill: trade.logistic_waybill || ''
        }
      end

      #如果满足自动化设置条件，打印物流单后订单自动发货
      auto_settings = current_account.settings.auto_settings
      if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "logistic_bill_printed_trade" && is_first_print
        trade.auto_deliver!
      end
    end

    respond_to do |format|
      format.json { render json: {list: list, has_wrong_trade: has_wrong_trade} }
    end
  end

  def verify_logistic_waybill
    waybills = params[:data]
    existed_waybills = Trade.where(:logistic_waybill.in => waybills, logistic_id: params[:logistic]).only(:logistic_waybill).collect(&:logistic_waybill).compact
    if existed_waybills == []
      render json: {existed_waybills: false}
    else
      render json: {existed_waybills: existed_waybills}
    end
  end

  def setup_logistics
    flag = true
    logistic = Logistic.find_by_id params[:logistic]
    if logistic && params[:data].present?
      params[:data].values.each do |info|
        trade = Trade.where(tid: info['tid']).first
        is_first_set = !trade.logistic_waybill.present?
        trade.logistic_code = logistic.try(:code)
        trade.service_logistic_id = params[:service_logistic_id]
        trade.logistic_waybill = info["logistic_waybill"].present? ? info["logistic_waybill"] : trade.tid
        trade.logistic_name = logistic.try(:name)
        trade.logistic_id = logistic.try(:id)
        trade.save
        trade.operation_logs.create(operated_at: Time.now, operation: '设置物流信息', operator_id: current_user.id, operator: current_user.name)

        #如果满足自动化设置条件，设置物流信息后订单自动发货
        auto_settings = current_account.settings.auto_settings
        if current_account.settings.auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "has_logistic_waybill_trade" && is_first_set
          trade.auto_deliver!
        end
      end
    else
      flag = false
    end
    render json: {isSuccess: flag}
  end

  def batch_print_logistic
    logistic = Logistic.find_by_id params[:logistic]
    success = true
    DeliverBill.any_in(id: params[:ids].split(',')).each do |bill|
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

  def print_process_sheets
    if params[:ids].present?
      @process_sheets = []
      bills = DeliverBill.any_in(id: params[:ids])
      bills.each do |bill|
        bill.trade.orders.each do |order|
          next if order.trade_property_memos.blank?
          order.trade_property_memos.each do |property_memo|
            next if property_memo.stock_in_bill_tid.present?
            sheet                   = {}
            sheet[:receiver_name]   = bill.trade.receiver_name
            sheet[:buyer_nick]      = bill.trade.buyer_nick
            sheet[:outer_id]        = order.outer_iid
            sheet[:cs_memo]         = order.cs_memo
            sheet[:property_values] = []
            order.trade_property_memos.where(id: property_memo.id).property_values.each do |value|
              dup_value = sheet[:property_values].each.find{|v| v[:name] == value.name}
              dup_value.present? ? dup_value[:value] += (","+value.value) : sheet[:property_values] << {name: value.name, value: value.value}
              @process_sheets << sheet
            end
          end
        end
      end
      respond_to do |format|
        format.json { render json: {success: true}}
        format.html {
          @print_num = Time.now.to_s(:number).to_i - 2*10**13
          bills.each_with_index{|b, index| b.print_batches.create(batch_num: @print_num, serial_num: (@print_num*10000+index+1))}
          bills.update_all(process_sheet_printed_at: Time.now)
          render 'print_process_sheets', layout: "blank_print"
        }
      end
    end
  end
end
