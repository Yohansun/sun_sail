window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    $.cookie.defaults['expires'] = 365

    # 不同角色显示的“操作”弹出项
    @trade_pops = {
      'cs': ['detail', 'seller', 'cs_memo', 'color', 'invoice'],
      'seller': ['detail', 'deliver', 'seller_confirm_deliver', 'seller_confirm_invoice'],
      'admin': ['*']
    }

    # 所有订单列
    @trade_cols = {
      'trade_source': '订单来源',
      'tid': '订单编号',
      'status': '当前状态',
      'status_history': '状态历史',
      'receiver_name': '客户姓名',
      'receiver_mobile_phone': '联系电话',
      'receiver_address': '联系地址',
      'buyer_message': '客户留言',
      'seller_memo': '卖家备注',
      'cs_memo': '客服备注',
      'color_info': '调色信息',
      'invoice_info': '发票信息',
      'seller': '送货经销商'
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
      'trades': '订单模式',
      'deliver': '出货单模式',
      'logistics': '物流单模式',
      'check': '验货模式',
      'send': '发货模式',
      'return': '退货模式',
      'refund': '退款模式',
      'invoice': '发票模式',
    }

    # 不同模式下可见订单列
    @trade_cols_visible_modes = {
      'trades': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'deliver': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'logistics': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'seller'],
      'check': ['trade_source', 'tid', 'status', 'status_history', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'send': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'return': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'refund': ['trade_source', 'tid', 'status', 'status_history', 'receiver_name', 'receiver_mobile_phone', 'receiver_address', 'buyer_message', 'seller_memo', 'cs_memo', 'color_info', 'invoice_info', 'seller'],
      'invoice': ['trade_source', 'tid', 'status', 'invoice_info'],
    }

    new MagicOrders.Routers.Areas()
    new MagicOrders.Routers.Trades()
    new MagicOrders.Routers.Sellers()
    Backbone.history.start(pushState: true)