# -*- encoding : utf-8 -*-
require 'rchardet19'

class TradesController < ApplicationController
  layout false, :only => :print_deliver_bill
  layout 'management', only: [:show_percent, :invoice_setting]
  respond_to :json, :xls
  before_filter :authorize,:only => [:index,:print_deliver_bill]

  include StockProductsLockable
  include MagicGift

  #include Dulux::Splitter

  def index
    if params[:batch_option] == "true"
      @trades = Trade.where(:_id.in => params[:ids])
    else
      offset = params[:offset] || 0
      limit = params[:limit] || 20
      if params[:search_id].present?
        trade_search = TradeSearch.find(params["search_id"]) rescue trade_search = nil
        if trade_search.present? && trade_search.search_hash.present?
          params[:search] = trade_search.search_hash
        end
      end
      @trades = Trade.where(:news.lt => params[:news] || 3).filter(current_account, current_user, params)
    end
    @trades_count = @trades.count
    @trades = TradeDecorator.decorate(@trades.limit(limit).skip(offset).order_by(:created.desc))

    if @trades_count > 0
      respond_with @trades
    else
      render json: []
    end
  end

  def export
    @report = TradeReport.new
    @report.account_id = current_account.id
    @report.request_at = Time.now
    @report.user_id = current_user.id

    if params[:search]
      params['search'] =  params['search'].select {|k,v| v != "undefined"  }
      params['search'].each do |k,v|
        array_flag = false
        v = v.join("&") and array_flag = true if v.is_a?(Array)
        guess_encoding = CharDet.detect(v, :silent => true).encoding
        if guess_encoding != "utf-8"
          v.force_encoding(guess_encoding)
          v.encode!("utf-8")
        else
          v.force_encoding("utf-8")
        end
        v = v.split("&") if array_flag == true
        params['search'][k] = v
      end
    end

    @report.conditions = params.select {|k,v| !['limit','offset', 'action', 'controller'].include?(k)}
    @report.save
    respond_to do |format|
      format.js
    end
  end

  def notifer
    trade_type = params[:trade_type]
    timestamp = Time.at(params[:timestamp].to_i)

    @trades = Trade

    if current_user.seller.present?
      unless current_user.seller == nil
        @trades = @trades.where seller_id: current_user.seller.try(:id)
      else
        render json: []
        return
      end
    end

    case params[:trade_type]
    when 'taobao'
      trade_type = 'TaobaoTrade'
    when 'taobao_fenxiao'
      trade_type = 'TaobaoPurchaseOrder'
    when 'jingdong'
      trade_type = 'JingdongTrade'
    when 'shop'
      trade_type = 'ShopTrade'
    else
      trade_type = nil
    end

    if trade_type
      @trades = @trades.where(_type: trade_type)
    end

    @new_trades_count = @trades.where(:created.gt => timestamp).count
    render json: @new_trades_count
  end

  def show
    @trade = TradeDecorator.decorate(Trade.where(_id: params[:id]).first || Trade.deleted.where(_id: params[:id]).first)
    # if params[:splited]
    #   @splited_orders = matched_seller_info(@trade)
    # end
    respond_with @trade
  end

  def update
    @trade = Trade.where(_id: params[:id]).first || Trade.deleted.where(_id: params[:id]).first
    notifer_seller_flag = false

    # 分流
    if params[:seller_id]
      if params[:seller_id] != "void"
        seller = current_account.sellers.find(params[:seller_id])
        @trade.dispatch!(seller) if seller
      elsif params[:seller_id] == "void"
        @trade.reset_seller
      end
    end

    # 发货
    if params[:delivered_at] == true
      @trade.delivered_at = Time.now
      @trade.change_status_to_deliverd
      if params['logistic_info'] == '其他' and @trade.logistic_waybill.nil?
        logistic = current_account.logistics.find_by_name '其他'
        if logistic
          @trade.logistic_waybill = @trade.tid
          @trade.logistic_name = logistic.name
          @trade.logistic_code = logistic.code
          @trade.logistic_id = logistic.id
        end
      end
    end

    # 设置物流信息
    if params[:setup_logistic] == true
      logistic = current_account.logistics.find_by_id params[:logistic_id]
      unless @trade.logistic_id.present? && params[:delivered_at] == true
        @trade.logistic_id = logistic.try(:id)
        @trade.logistic_name = logistic.try(:name)
        @trade.logistic_code = logistic.try(:code)
        @trade.service_logistic_id = params[:service_logistic_id]
        @trade.logistic_waybill = params[:logistic_waybill].present? ? params[:logistic_waybill] : @trade.tid
      end
    end

    # 赠品更新
    delete_gift_orders(@trade, params[:delete_gifts]) if params[:delete_gifts]
    add_gift_orders(@trade, params[:add_gifts]) if params[:add_gifts]

    # 异常标注及解决
    unless params[:reason].blank?
      state = @trade.unusual_states.create!(reason: params[:reason], plan_repair_at: params[:plan_repair_at], note: params[:state_note], created_at: Time.now, reporter: current_user.name, repair_man: params[:repair_man])
      state.update_attributes(key: state.add_key)
      role_key = current_user.roles.first.name
      state.update_attributes!(reporter_role: role_key)
    end

    unless params[:state_id].blank?
      states = @trade.unusual_states.where(_id: params[:state_id], repaired_at: nil).all
      states.update_all(repair_man: current_user.name, repaired_at: Time.now)
    end

    # 物流拆分？
    if params[:logistic_ids].present?
      @trade.split_logistic(params[:logistic_ids])
    end

    # 修改信息
    [:receiver_name,
     :receiver_mobile,
     :receiver_state,
     :receiver_city,
     :receiver_district,
     :receiver_address,

     :modify_payment,
     :modify_payment_at,
     :modify_payment_no,
     :modify_payment_memo,

     :logistic_waybill,
     :logistic_memo,

     :invoice_type,
     :invoice_name,
     :invoice_content,
     :invoice_date,
     :invoice_number,

     :gift_memo
    ].each{|key|
      if params[key]
        if params[key].respond_to?(:strip)
          @trade[key] = params[key].strip
        else
          @trade[key] = params[key]
        end
      end
    }

    # 标注当前时间
    [:deliver_bill_printed_at,
     :confirm_refund_at,
     :confirm_return_at,
     :confirm_check_goods_at,
     :confirm_color_at,
     :seller_confirm_deliver_at,
     :confirm_receive_at,
     :request_return_at,
     :seller_confirm_invoice_at
    ].each{|key|
      @trade[key] = Time.now if params[key]
    }

    if params[:cs_memo]
      @trade.cs_memo = params[:cs_memo].strip
      if @trade.changed.include? 'cs_memo'
        notifer_seller_flag = true
      end
      logistic = Logistic.find_by_id params[:logistic_id]
      if logistic
        @trade.logistic_name = logistic.name
        @trade.logistic_code = logistic.code
        @trade.logistic_id = logistic.id
        @trade.service_logistic_id = params[:service_logistic_id]
      end
    end

    #客服备注，调色信息，唯一码等子订单信息修改
    if params[:orders].present?
      params[:orders].each do |item|
        order = @trade.orders.where(_id: item[:id]).first
        if order
          order.cs_memo = item[:cs_memo]
          if order.changed.include? 'cs_memo'
            notifer_seller_flag = true
          end
          if item[:color_num]
            item[:color_num].each_with_index do |num, index|
              if num.blank?
                order.color_num[index] = nil
                order.color_hexcode[index] = nil
                order.color_name[index] = nil
              else
                order.color_num[index] = num
                color = Color.find_by_num num
                order.color_hexcode[index] = color.try(:hexcode)
                order.color_name[index] = color.try(:name)
              end
            end
          end
          if item[:barcode]
            item[:barcode].each_with_index do |code, index|
              order.barcode[index] = code
            end
          end
        end
      end
    end

    #手动发送邮件短信
    unless params[:notify_content].blank?
      notify = @trade.manual_sms_or_emails.create(
        notify_sender:    params[:notify_sender],
        notify_receiver:  params[:notify_receiver],
        notify_theme:     params[:notify_theme],
        notify_content:   params[:notify_content],
        notify_type:      params[:notify_type]
      )
    end

    # 多退少补，申请线下退款
    ["add_ref", "return_ref", "refund_ref"].each do |ref_type|
      syms = ['hash', 'status', 'memo'].inject({}){|hash, param| hash.merge(param => (ref_type + "_" + param).to_sym)}
      if params[syms['hash']] && params[syms['hash']][:ref_batch]
        @trade.update_batch(current_user, ref_type, params[syms['hash']])
      end
      if params[syms['status']]
        @trade.send(ref_type.to_sym).change_status(current_user, params[syms['status']], params[syms['memo']])
      end
    end

    # 添加属性备注
    if params[:property_memos].present?

      # 还原入库单信息，删除备注
      BillPropertyMemo.where(:stock_in_bill_tid.in => @trade.trade_property_memos.map(&:stock_in_bill_tid)).update_all(used: false)
      @trade.trade_property_memos.delete_all

      # 重新添加备注
      params[:property_memos].each do |order_id, infos|
        order = @trade.orders.where(_id: order_id).first
        if order
          infos.each do |key, info|
            values = info['values'].reject{|value| value.blank? || value['id'].blank? || value['value'].blank? }
            next if values.count == 0
            property_memo = order.trade_property_memos.create(
              trade_id:          @trade.id,
              outer_id:          info['outer_id'],
              account_id:        current_account.id,
              stock_in_bill_tid: info['stock_in_bill_tid']
            )
            used_memo = BillPropertyMemo.where(stock_in_bill_tid: info['stock_in_bill_tid']).first
            used_memo.update_attributes(used: true) if used_memo.present?
            values.each do |value|
              name = CategoryPropertyValue.find(value['id']).category_property.name
              property_memo.property_values.create(
                category_property_value_id: value['id'],
                value:                      value['value'],
                name:                       name
              )
            end
          end
        end
      end
    end

    if @trade.save!
      @trade = TradeDecorator.decorate(@trade)
      if notifer_seller_flag && @trade.is_paid_not_delivered && @trade.seller
        TradeDispatchEmail.perform_async(@trade.id, @trade.seller_id, 'second')
        TradeDispatchSms.perform_async(@trade.id, @trade.seller_id, 'second')
      end

      #写入操作日志
      if params[:operation]
        if params[:operation] == "确认退货"
          operation = @trade.ref_batches.where(ref_type: "return_ref").first.operation_text
          @trade.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: operation)
        elsif params[:operation] == "确认退款"
          operation = @trade.ref_batches.where(ref_type: "refund_ref").first.operation_text
          @trade.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: operation)
        else
          @trade.operation_logs.create(operated_at: Time.now, operator: current_user.name, operator_id: current_user.id, operation: params[:operation])
        end
      end

      respond_with(@trade) do |format|
        format.json { render :show, status: :ok }
      end
    else
      head :unprocessable_entity
    end
  end

  def batch_check_goods
    Trade.where(:_id.in => params[:ids]).update_all(confirm_check_goods_at: Time.now)
    render json: {isSuccess: true}
  end

  def batch_export
    @report = TradeReport.new
    @report.account_id = current_account.id
    @report.request_at = Time.now
    @report.user_id = current_user.id
    @report.batch_export_ids = params[:ids].join(',')
    @report.save
    @report.export_report
    render json: {isSuccess: true}
  end

  def verify_add_gift
    trades = Trade.where(:_id.in => params[:ids])
    types = trades.map(&:_type).uniq
    if (types - ['TaobaoTrade', 'CustomTrade', 'Trade']).count > 0
      has_jingdong_trade = true
    end
    if trades.where(:main_trade_id.ne => nil).count > 0
      has_gift_trade = true
    end
    trades_added_gift = trades.where(:taobao_orders.elem_match => {local_sku_id: (params[:sku_id] == "" ? nil : params[:sku_id].to_i)})
    tids = trades_added_gift.all.map(&:tid).join(",") rescue nil
    render json: {tids: tids, has_jingdong_trade: has_jingdong_trade, has_gift_trade: has_gift_trade}
  end

  def batch_add_gift
    trades = Trade.where(:_id.in => params[:ids])
    trades.each do |trade|
      trade.gift_memo = params[:gift_memo]
      add_gift_orders(trade, params[:add_gifts]) if params[:add_gifts]
      trade.operation_logs.create(operated_at: Time.now, operation: params[:operation], operator_id: current_user.id, operator: current_user.name)
    end
    render json: {isSuccess: true}
  end

  def lock_trade
    trade = Trade.where(_id: params[:id]).first
    if (trade.stock_out_bill && ["CANCELING", "STOCKED", "CANCELED_FAILED", "SYNCKED"].include?(trade.stock_out_bill.status)) || trade.dispatched_at.present?
      render json: {status_changed: true}
    else
      trade.update_attributes(is_locked: true)
      trade.delete
      render json: {id: trade.id}
    end
  end

  def activate_trade
    trade = Trade.deleted.where(_id: params[:id]).first
    trade.restore
    trade.update_attributes(is_locked: false)
    TaobaoTradePuller.update_by_tid(trade) if trade._type == "TaobaoTrade"
    render json: {id: trade.id}
  end

  def seller_for_area
    trade = Trade.find params[:id]
    area = Area.find params[:area_id]

    seller = SellerMatcher.match_trade_seller(trade.id, area)
    seller ||= trade.default_seller

    seller_id = nil
    seller_name = '无对应经销商'
    dispatchable = false

    if seller
      seller_id = seller.id
      seller_name = seller.name
      dispatchable = true
      errors = can_lock_products?(trade.id, seller.id).join(',')
      if errors.present?
        seller_name += "(无法分派：#{errors})"
        dispatchable = false
      end
    end

    respond_to do |format|
      format.json { render json: {seller_id: seller_id, seller_name: seller_name, dispatchable: dispatchable} }
    end
  end

  def sellers_info
    trade = Trade.find params[:id]
    logger.debug matched_seller_info(trade).inspect
    respond_to do |format|
      format.json { render json: matched_seller_info(trade) }
    end
  end

  def estimate_dispatch
    trade = Trade.find params[:id]
    seller_id = trade.default_seller.try(:id)
    if seller_id.blank?
      dispatchable = false
      dispatch_error = "无对应经销商"
    else
      dispatchable = true
      errors = can_lock_products?(trade.id, seller_id).join(',')
      if errors.present?
        dispatch_error = "(无法分派：#{errors})"
        dispatchable = false
      end
    end

    respond_to do |format|
      format.json { render json: {seller_id: seller_id, dispatch_error: dispatch_error, dispatchable: dispatchable} }
    end
  end

  # def split_trade
  #   @trade = Trade.find params[:id]
  #   new_trade_ids = if current_account.key == 'dulux'
  #     split_orders(@trade)
  #   else
  #     TradeSplitter.new(@trade).split!
  #   end

  #   @trade.operation_logs.build(operated_at: Time.now, operation: '拆单', operator_id: current_user.id, operator: current_user.name)
  #   respond_to do |format|
  #     format.json { render json: {ids: new_trade_ids} }
  #   end
  # end

  def batch_deliver
    Trade.any_in(_id: params[:ids]).each do |trade|
      trade.delivered_at = Time.now
      trade.change_status_to_deliverd
      trade.save # this will trigger observer.
    end
    render json: {isSuccess: true}
  end

  def deliver_list
    respond_to do |format|
      format.json { render json: Trade.find(params[:ids]).to_json }
    end
  end

  # def recover
  #   trade = Trade.find params[:id]
  #   parent_trade = Trade.deleted.where(tid: trade.tid, splitted_tid: nil).first

  #   success = if parent_trade
  #     Trade.where(tid: trade.tid).delete_all
  #     parent_trade.operation_logs.build(operated_at: Time.now, operation: '订单合并')
  #     parent_trade.save
  #     parent_trade.restore
  #   end

  #   respond_to do |format|
  #     format.json { render json: {is_success: success.present? } }
  #   end
  # end

  def show_percent
    @users = current_account.users.where(can_assign_trade: true).where(active: true).order(:created_at)
  end

  def assign_percent
    users = User.where("id in (?)", params[:user_ids]).order(:created_at)
    percent = params[:percent].each
    users.each {|u| u.trade_percent = (percent.next.to_i rescue nil);u.save}
    redirect_to trades_show_percent_path
  end

  def invoice_setting
    @setting = current_account.settings
  end

  def change_invoice_setting
    if params[:settings][:open_auto_mark_invoice] == "1"
      current_account.settings.open_auto_mark_invoice = 1
    else
      current_account.settings.open_auto_mark_invoice = nil
    end
    flash[:notice] = "保存成功"
    redirect_to trades_invoice_setting_path
  end

  def merge
    ids = params[:ids]
    trades = Trade.find ids
    merged_trade = Trade.merge_trades trades
    render :json=>merged_trade
  end

  def split
    trade = Trade.find params[:id]
    trade.split

    render :text=>"ok"
  end

  def sort_product_search
    params[:search] ||= {}

    if params[:ids].present?
      picked_skus = []
      trades = current_account.trades.where(:id.in => params[:ids])
      trades.each_with_index do |trade, index|
        trade.regular_orders.each do |order|
          order.skus_info_with_offline_refund.each do |sku_info|
            has_no_num = true
            picked_skus.each do |n|
              if n[:title] == sku_info[:sku_title]
                n[:num] += sku_info[:number]
                has_no_num = false
              end
            end
            picked_skus << {title: sku_info[:name], num_iid: sku_info[:outer_id] || "", num: sku_info[:number], category: sku_info[:category_name], sku_properties: sku_info[:sku_title].gsub(sku_info[:name], "")} if has_no_num
          end
        end
      end

      picked_skus = picked_skus.dup.keep_if {|picked_sku|
        params[:search].all? {|k,v| v.present? ? picked_sku[k.to_sym].delete(" ") == v.delete(" ") : true }
        } if params[:search].present?

      display_skus = Kaminari.paginate_array(picked_skus).page(params[:page]).per(20)
      total_page = display_skus.total_pages
      total_page += 1 if picked_skus.count == 0

      @batch_sort_num = Time.now.to_s(:number).to_i - 2*10**13
      trades.update_all(batch_sort_num: @batch_sort_num)

      respond_to do |format|
        format.json { render json: {skus: display_skus, total_page: total_page}}
        format.html {
          @print_skus = picked_skus
          render 'sort_product_search',layout: "blank_print"
        }
      end
    end
  end

  def match_icp_bills
    values = params[:property_memo][:values].reject{|key, value| value['id'].blank? || value['value'].blank? }
    bill_memos = BillPropertyMemo.where(
      outer_id:   params[:property_memo][:outer_id],
      account_id: current_account.id,
      used:       false,
      :property_values.with_size => values.count
    )
    memo_ids = bill_memos.map(&:id)
    values.each do |key, value|
      current_ids = bill_memos.where(
        "property_values.category_property_value_id" => value['id'].to_i,
        "property_values.value"                      => value['value']
      ).map(&:id)
      memo_ids &= current_ids
    end
    bills = BillPropertyMemo.where(:_id.in => memo_ids).collect{ |memo| {id: memo.stock_in_bill.tid, text: memo.stock_in_bill.tid} if memo.stock_in_bill.status == "STOCKED" }
    render json: {bills: bills}
  end

end
