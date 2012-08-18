window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
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
    # 初始化时需要隐藏的订单列
    @trade_cols_hidden = []

    new MagicOrders.Routers.Areas()
    new MagicOrders.Routers.Trades()
    new MagicOrders.Routers.Sellers()
    Backbone.history.start(pushState: true)