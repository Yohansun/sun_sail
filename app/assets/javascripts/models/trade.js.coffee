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
    type = this.attributes.trade_source
    trades = MagicOrders.trade_pops['trades']

    if this.attributes.is_locked is true
      enabled_items.push('activate_trade')

    if this.attributes.is_locked isnt true
      if MagicOrders.role_key == "super_admin"
        enabled_items.push('seller') #订单分派,分派重置

      if this.status_text == "等待付款"
        if $.inArray('modify_payment',trades) > -1
          enabled_items.push('modify_payment') #金额调整

        enabled_items.push('lock_trade')

      if this.attributes.is_paid_not_delivered
        enabled_items.push('refund_ref')
        enabled_items.push('modify_receiver_information')
        enabled_items.push('merge_trades_manually')
        if this.attributes.merged_trade_ids && this.attributes.merged_trade_ids.length > 0
          enabled_items.push('split_merged_trades')

        if this.attributes.trade_source == "人工" && not this.attributes.seller_id
          enabled_items.push('edit_handmade_trade') #编辑人工订单

        if this.attributes.seller_id
          if MagicOrders.role_key == 'admin' || $.inArray('seller',trades) > -1
            enabled_items.push('seller')
        else
          enabled_items.push('seller')  #订单分派,分派重置

        if this.attributes.splitted_tid && $.inArray('recover',trades) > -1
          enabled_items.push('recover') #订单合并
        else
          if not this.attributes.seller_id && $.inArray('trade_split',trades) > -1
            enabled_items.push('trade_split') #订单拆分


        if this.attributes.is_locked is false and this.attributes.seller_id is null
          enabled_items.push('lock_trade') #订单锁定

        if this.attributes.seller_confirm_invoice_at is undefined && type != '赠品' && type != '一号店' && $.inArray('invoice',trades) > -1
          enabled_items.push('invoice') #申请开票

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && $.inArray('color',trades) > -1
            enabled_items.push('color') #申请调色

        if this.attributes.dispatched_at isnt undefined
          if $.inArray('setup_logistic',trades) > -1
            enabled_items.push('setup_logistic') #物流单号设置
          if $.inArray('batch_setup_logistic',trades) > -1
            enabled_items.push('batch_setup_logistic') #物流单号设置
          if $.inArray('deliver',trades) > -1
            enabled_items.push('deliver') #订单发货
          if $.inArray('confirm_check_goods',trades) > -1
            enabled_items.push('confirm_check_goods') #确认验货

          if this.attributes.trade_source isnt '京东'
            if MagicOrders.enable_trade_deliver_bill_spliting && not this.attributes.has_split_deliver_bill
              if this.attributes.seller_id in MagicOrders.enable_trade_deliver_bill_spliting_sellers
                enabled_items.push('logistic_split') #物流拆分

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && this.attributes.has_color_info is true
            enabled_items.push('confirm_color') #确认调色

      if this.attributes.is_paid_and_delivered
        if this.attributes.add_ref && this.attributes.add_ref['status'] == 'request_add_ref' && $.inArray('confirm_add_ref',trades) > -1
          enabled_items.push('add_ref') #确认补货
        if (this.attributes.add_ref == null) && $.inArray('request_add_ref',trades) > -1
          enabled_items.push('add_ref') #申请补货
        if (this.attributes.return_ref == null || this.attributes.return_ref['status'] == 'cancel_return_ref') && $.inArray('request_return_ref',trades) > -1
          enabled_items.push('return_ref') #申请退货
        if this.attributes.return_ref && (this.attributes.return_ref['status'] == 'confirm_return_ref' || this.attributes.return_ref['status'] == 'request_return_ref') && $.inArray('confirm_return_ref',trades) > -1
          enabled_items.push('return_ref') #确认退货
        if this.attributes.return_ref && this.attributes.return_ref['status'] == 'return_ref_money' && $.inArray('cancel_return_ref',trades) > -1
          enabled_items.push('return_ref') #取消退货
        if $.inArray('logistic_memo',trades) > -1
          enabled_items.push('logistic_memo') #物流公司备注

        if this.attributes.seller_confirm_invoice_at is undefined && type != '赠品' && type != '一号店' && $.inArray('invoice',trades) > -1
          enabled_items.push('invoice') #申请开票

        if MagicOrders.enable_module_colors is 1
          if this.attributes.confirm_color_at is undefined && $.inArray('color',trades) > -1
            enabled_items.push('color') #申请调色

        if this.attributes.seller_confirm_deliver_at isnt undefined && $.inArray('confirm_receive',trades) > -1
          enabled_items.push('confirm_receive') #确认买家已收货

        # if $.inArray('logistic_waybill',trades) > -1
        #  enabled_items.push('logistic_waybill') #物流单号设置

      # switch state
      #   # when "TRADE_NO_CREATE_PAY" # "没有创建支付宝交易"
      #   when "WAIT_BUYER_PAY" # "等待付款"
      #     if $.inArray('modify_payment',trades) > -1
      #       enabled_items.push('modify_payment') #金额调整
      #   when "WAIT_SELLER_SEND_GOODS" # "已付款，待发货"
      #     enabled_items.push('modify_receiver_information')
      #     enabled_items.push('merge_trades_manually')
      #     if this.attributes.merged_trade_ids && this.attributes.merged_trade_ids.length > 0
      #       enabled_items.push('split_merged_trades')

      #     if this.attributes.trade_source == "人工" && not this.attributes.seller_id
      #       enabled_items.push('edit_handmade_trade') #编辑人工订单

      #     if this.attributes.seller_id
      #       if MagicOrders.role_key == 'admin' || $.inArray('seller',trades) > -1
      #         enabled_items.push('seller')
      #     else
      #       enabled_items.push('seller')  #订单分派,分派重置

      #     if this.attributes.splitted_tid && $.inArray('recover',trades) > -1
      #       enabled_items.push('recover') #订单合并
      #     else
      #       if not this.attributes.seller_id && $.inArray('trade_split',trades) > -1
      #         enabled_items.push('trade_split') #订单拆分

      #     if this.attributes.seller_confirm_invoice_at is undefined && type != '赠品' && $.inArray('invoice',trades) > -1
      #       enabled_items.push('invoice') #申请开票

      #     if MagicOrders.enable_module_colors is 1
      #       if this.attributes.confirm_color_at is undefined && $.inArray('color',trades) > -1
      #         enabled_items.push('color') #申请调色

      #     if this.attributes.dispatched_at isnt undefined
      #       if $.inArray('setup_logistic',trades) > -1
      #         enabled_items.push('setup_logistic') #物流单号设置
      #       if $.inArray('batch_setup_logistic',trades) > -1
      #         enabled_items.push('batch_setup_logistic') #物流单号设置
      #       if $.inArray('deliver',trades) > -1
      #         enabled_items.push('deliver') #订单发货
      #       if $.inArray('confirm_check_goods',trades) > -1
      #         enabled_items.push('confirm_check_goods') #确认验货

      #       if this.attributes.trade_source isnt '京东'
      #         if MagicOrders.enable_trade_deliver_bill_spliting && not this.attributes.has_split_deliver_bill
      #           if this.attributes.seller_id in MagicOrders.enable_trade_deliver_bill_spliting_sellers
      #             enabled_items.push('logistic_split') #物流拆分

      #     if MagicOrders.enable_module_colors is 1
      #       if this.attributes.confirm_color_at is undefined && this.attributes.has_color_info is true
      #         enabled_items.push('confirm_color') #确认调色

      #     if $.inArray('batch_add_gift',trades) > -1
      #       enabled_items.push('batch_add_gift') #批量添加赠品

      #   when "WAIT_BUYER_CONFIRM_GOODS" # "已付款，已发货"
      #     if this.attributes.add_ref && this.attributes.add_ref['status'] == 'request_add_ref' && $.inArray('confirm_add_ref',trades) > -1
      #       enabled_items.push('add_ref') #确认补货
      #     if (this.attributes.add_ref == null) && $.inArray('request_add_ref',trades) > -1
      #       enabled_items.push('add_ref') #申请补货
      #     if (this.attributes.return_ref == null || this.attributes.return_ref['status'] == 'cancel_return_ref') && $.inArray('request_return_ref',trades) > -1
      #       enabled_items.push('return_ref') #申请退货
      #     if this.attributes.return_ref && (this.attributes.return_ref['status'] == 'confirm_return_ref' || this.attributes.return_ref['status'] == 'request_return_ref') && $.inArray('confirm_return_ref',trades) > -1
      #       enabled_items.push('return_ref') #确认退货
      #     if this.attributes.return_ref && this.attributes.return_ref['status'] == 'return_ref_money' && $.inArray('cancel_return_ref',trades) > -1
      #       enabled_items.push('return_ref') #取消退货
      #     if $.inArray('logistic_memo',trades) > -1
      #       enabled_items.push('logistic_memo') #物流公司备注

      #     if this.attributes.seller_confirm_invoice_at is undefined && type != '赠品' && $.inArray('invoice',trades) > -1
      #       enabled_items.push('invoice') #申请开票

      #     if MagicOrders.enable_module_colors is 1
      #       if this.attributes.confirm_color_at is undefined && $.inArray('color',trades) > -1
      #         enabled_items.push('color') #申请调色

      #     if this.attributes.seller_confirm_deliver_at isnt undefined && $.inArray('confirm_receive',trades) > -1
      #       enabled_items.push('confirm_receive') #确认买家已收货

      #     # if $.inArray('logistic_waybill',trades) > -1
      #     #  enabled_items.push('logistic_waybill') #物流单号设置

      # when "TRADE_BUYER_SIGNED" # "买家已签收,货到付款专用"
      # when "TRADE_FINISHED" # "交易成功"
      # when "TRADE_CLOSED" # "交易已关闭"
      # when "TRADE_CLOSED_BY_TAOBAO" # "交易被淘宝关闭"

      if this.attributes.invoice_name && this.attributes.seller_confirm_invoice_at is undefined && this.attributes.status_text isnt "申请退款" && type != "一号店" && type != "赠品" && $.inArray('seller_confirm_invoice',trades) > -1 && this.attributes.seller_id
        enabled_items.push('seller_confirm_invoice') #确认开票

      if this.attributes.pay_time
        if $.inArray('barcode',trades) > -1
          enabled_items.push('barcode') #输入唯一码

      if this.attributes.consign_time # 发货后才可操作
        if this.attributes.request_return_at is undefined && $.inArray('request_return',trades) > -1
          enabled_items.push('request_return') #申请退货

        if this.attributes.request_return_at && this.attributes.confirm_return_at is undefined && $.inArray('confirm_return',trades) > -1
          enabled_items.push('confirm_return') #确认退货

      if this.attributes.pay_time # 付款后才可操作
        if this.attributes.confirm_return_at && this.attributes.confirm_refund_at is undefined && $.inArray('confirm_refund',trades) > -1
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

      if $.inArray('operation_log',trades) > -1
        enabled_items.push('operation_log') #订单日志

      if $.inArray('manual_sms_or_email',trades) > -1
        enabled_items.push('manual_sms_or_email') #发短信/邮件

      if $.inArray('batch_export',trades) > -1
        enabled_items.push('batch_export') #发短信/邮件

      if this.attributes.seller_confirm_deliver_at is undefined && this.attributes.consign_time && $.inArray('seller_confirm_deliver',trades) > -1
        enabled_items.push('seller_confirm_deliver') #确认发货


      if type != '赠品' && type != '京东' && type != '一号店'
        enabled_items.push('gift_memo') #赠品备注
      if $.inArray('invoice_number',trades) > -1
        enabled_items.push('invoice_number') #发票号设置
      if $.inArray('mark_unusual_state',trades) > -1
        enabled_items.push('mark_unusual_state') #标注异常
      if $.inArray('cs_memo',trades) > -1
        enabled_items.push('cs_memo') #客服备注
      if $.inArray('detail',trades) > -1
        enabled_items.push('detail') #订单详情

    enabled_items
