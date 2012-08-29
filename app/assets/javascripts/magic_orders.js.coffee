window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    $.cookie.defaults['expires'] = 365

    # 不同角色显示的“操作”弹出项
    @trade_pops = {
      #roles
      'cs':                      ['detail', 'seller', 'cs_memo', 'color', 'invoice'],
      'seller':                  ['detail', 'deliver', 'seller_confirm_deliver', 'seller_confirm_invoice'],
      'admin':                   ['*'],
      #trade_mode
      'trades':                  ['detail', 'seller', 'cs_memo', 'color', 'invoice', 'deliver', 'seller_confirm_deliver', 'seller_confirm_invoice'],
      'deliver':                 ['detail'],
      'logistics':               ['detail'],
      'check':                   ['detail'],
      'send':                    ['detail'],
      'return':                  ['detail'],
      'refund':                  ['detail'],
      'invoice':                 ['detail']
    }

    # 所有订单列
    @trade_cols = {
      'trade_source':            '订单来源',
      'tid':                     '订单编号',
      'status':                  '当前状态',
      'status_history':          '状态历史',
      'receiver_name':           '客户姓名',
      'receiver_mobile_phone':   '联系电话',
      'receiver_address':        '联系地址',
      'buyer_message':           '客户留言',
      'seller_memo':             '卖家备注',
      'cs_memo':                 '客服备注',
      'color_info':              '调色信息',
      'invoice_info':            '发票信息',
      'seller':                  '配送经销商',

      'receiver_id':             '客户ID',             #new add
      'delivery_bill':           '出货单',
      'delivery_bill_id':        '出货单编号',
      'delivery_bill_status':    '出货单状态',
      'order_goods':             '商品详细',
      'logistic_bill':           '物流单',
      'logistic_waybill':        '物流单号',
      'logistic_company':        '物流公司',
      'invoice_type':            '发票类型',
      'invoice_name':            '发票开头',
      'invoice_value':           '开票金额',
      'invoice_date':            '完成日期',
      'order_split':             '拆分',
      'operator':                '操作人'
    }
    # cache keys
    @trade_cols_keys = _.keys(@trade_cols)

    # 可见订单列（与订单模式选择有关），默认为全部
    @trade_cols_visible = @trade_cols_keys

    # 初始化时需要隐藏的订单列
    if $.cookie('trade_cols_hidden')
      @trade_cols_hidden = $.cookie('trade_cols_hidden').split(',')
    else
      @trade_cols_hidden = []

    # 订单模式可选项列表
    @trade_modes = {
      'trades':                  '订单模式',
      'deliver':                 '出货单模式',
      'logistics':               '物流单模式',
      'check':                   '验货模式',
      'send':                    '发货模式',
      'return':                  '退货模式',
      'refund':                  '退款模式',
      'invoice':                 '发票模式',
    }
    
    # 订单模式初始化为'trades'
    @trade_mode = 'trades'

    # 不同模式下可见订单列
    @trade_cols_visible_modes = {
      'trades':                  ['trade_source','tid','status','status_history','receiver_id','receiver_name','receiver_mobile_phone','receiver_address','buyer_message','seller_memo','cs_memo','color_info','invoice_info','delivery_bill','logistic_bill','seller','order_split','operator'],
      'deliver':                 ['tid','delivery_bill_id','delivery_bill_status','trade_source','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo'],
      'logistics':               ['tid','delivery_bill_id','logistic_waybill','logistic_company','trade_source','order_goods','receiver_name','receiver_mobile_phone','receiver_address','invoice_info','seller','cs_memo','operator'],
      'check':                   ['tid','delivery_bill_id','status_history','delivery_bill_status','trade_source','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo','operator'],
      'send':                    ['tid','delivery_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo','operator'],
      'return':                  ['tid','delivery_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo','operator'],
      'refund':                  ['tid','delivery_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo','operator'],
      'invoice':                 ['tid','delivery_bill_id','status_history','trade_source','order_goods','invoice_type','invoice_name','invoice_value','invoice_date','seller','cs_memo','operator'],
    }

    new MagicOrders.Routers.Areas()
    new MagicOrders.Routers.Trades()
    new MagicOrders.Routers.Sellers()
    Backbone.history.start(pushState: true)