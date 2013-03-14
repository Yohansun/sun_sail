class MagicOrders.Models.Trade extends Backbone.Model
  urlRoot: '/api/trades'

  validate: (attrs) ->
  	# if attrs.logistic_code =='YTO' and (/^(0|1|2|3|5|6|7|8|E|D|F|G|V|W|e|d|f|g|v|w)[0-9]{9}$/.test(attrs.logistic_waybill)) == false
   #    return "格式错误,请输入10位物流单号"
  	# else if attrs.logistic_code =='ZTO' and (/^((618|680|778|688|618|828|988|118|888|571|518|010|628|205|880|717|718|728|738|761|762|763|701|757)[0-9]{9})$|^((2008|2010|8050|7518)[0-9]{8})$/.test(attrs.logistic_waybill)) == false
   #    return "格式错误,请输入12位物流单号"
    # else if attrs.logistic_code == 'OTHER' and (/^[0-9A-Za-z]{13}$/.test(attrs.logistic_waybill)) == false
    #   return "格式错误,请输入13位物流单号"

    # if attrs.invoice_name == ""
    #   return "发票抬头不能为空"

  check_operations: ->
    enabled_items = []
    state = this.attributes.status
    type = this.attributes.trade_type
    switch state
      # when "TRADE_NO_CREATE_PAY" # "没有创建支付宝交易"
      when "WAIT_BUYER_PAY" # "等待付款"
        enabled_items.push('modify_payment') #金额调整
      when "WAIT_SELLER_SEND_GOODS" # "已付款，待发货"
        if this.attributes.seller_id
          if MagicOrders.role_key == 'admin' || MagicOrders.role_key == 'cs'
            enabled_items.push('seller') #分流重置
        else
          enabled_items.push('seller') #订单分流

        if this.attributes.splitted_tid
          enabled_items.push('recover') #订单合并
        else
          if not this.attributes.seller_id
            enabled_items.push('trade_split') #订单拆分

        if MagicOrders.trade_type in ['logistic_waybill_exist', 'logistic_waybill_void']
          enabled_items.push('setup_logistic') #物流单号设置

        if this.attributes.seller_confirm_invoice_at is undefined && type != "CustomTrade"
          enabled_items.push('invoice') #申请开票

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && MagicOrders.role_key isnt 'seller'
            enabled_items.push('color') #申请调色

        if this.attributes.dispatched_at isnt undefined
          enabled_items.push('deliver') #订单发货
          enabled_items.push('confirm_check_goods') #确认验货

          if this.attributes.trade_source isnt '京东'
            if MagicOrders.enable_trade_deliver_bill_spliting && not this.attributes.has_split_deliver_bill
              if this.attributes.seller_id in MagicOrders.enable_trade_deliver_bill_spliting_sellers
                enabled_items.push('logistic_split') #物流拆分

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && this.attributes.has_color_info is true
            enabled_items.push('confirm_color') #确认调色

      when "WAIT_BUYER_CONFIRM_GOODS" # "已付款，已发货"
        enabled_items.push('logistic_memo') #物流商备注

        if this.attributes.seller_confirm_invoice_at is undefined && type != "CustomTrade"
          enabled_items.push('invoice') #申请开票

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && MagicOrders.role_key isnt 'seller'
            enabled_items.push('color') #申请调色

        if this.attributes.seller_confirm_deliver_at isnt undefined
          enabled_items.push('confirm_receive') #确认买家已收货

        if MagicOrders.role_key == 'logistic'
          enabled_items.push('logistic_waybill') #物流单号设置

      # when "TRADE_BUYER_SIGNED" # "买家已签收,货到付款专用"
      # when "TRADE_FINISHED" # "交易成功"
      # when "TRADE_CLOSED" # "交易已关闭"
      # when "TRADE_CLOSED_BY_TAOBAO" # "交易被淘宝关闭"

    if this.attributes.invoice_name && this.attributes.seller_confirm_invoice_at is undefined && this.attributes.status_text isnt "申请退款"
      enabled_items.push('seller_confirm_invoice') #确认开票

    if this.attributes.pay_time
      if MagicOrders.role_key isnt 'seller'
        enabled_items.push('barcode') #输入唯一码

    if this.attributes.request_return_at is undefined
      enabled_items.push('request_return') #申请退货

    if this.attributes.request_return_at && this.attributes.confirm_return_at is undefined
      enabled_items.push('confirm_return') #确认退货

    if this.attributes.confirm_return_at && this.attributes.confirm_refund_at is undefined
      enabled_items.push('confirm_refund') #确认退款

    # enabled_items.push('check_goods') #验货
    # enabled_items.push('confirm_check_goods')#确认验货
    # enabled_items.push('refund') #申请退款
    # enabled_items.push('agree_refund') #同意退款
    # enabled_items.push('agree_return_goods') #同意退货
    # enabled_items.push('invoice_notice') #开票通知
    # enabled_items.push('export_deliver_bill') #导出发货单
    # enabled_items.push('export_logistic_bill') #导出物流单
    # enabled_items.push('export_invoice') #导出发票

    if MagicOrders.role_key isnt 'seller'
      enabled_items.push('operation_log') #订单日志

    if MagicOrders.role_key is 'admin' || MagicOrders.role_key is 'cs'
      enabled_items.push('manual_sms_or_email') #发短信/邮件

    if this.attributes.seller_confirm_deliver_at is undefined && this.attributes.consign_time
      enabled_items.push('seller_confirm_deliver') #确认发货


    if type != "CustomTrade"
      enabled_items.push('gift_memo') #赠品备注
      enabled_items.push('invoice_number') #发票号设置

    enabled_items.push('mark_unusual_state') #标注异常
    enabled_items.push('detail') #订单详情
    enabled_items