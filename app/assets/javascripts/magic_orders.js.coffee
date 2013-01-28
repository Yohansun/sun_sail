window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    $.cookie.defaults['expires'] = 365

    # 不同角色显示的“操作”弹出项
    #@trade_pops = {} #  MOVED TO TradeSetting.trade_pops

    # 所有订单列
    #@trade_cols = {} #   MOVED TO TradeSetting.trade_cols
    # cache keys
    @trade_cols_keys = _.keys(@trade_cols)

    # 可见订单列（与订单模式选择有关），默认为全部
    @trade_cols_visible = @trade_cols_keys

    # 订单模式初始化
    @trade_mode = 'trades'
    if _.str.include(location.hash.toString(),'-')
      @trade_mode = _(_(location.hash.toString()).strLeft('-')).strRight("/")

    @trade_type = ''

    # 初始化时需要隐藏的订单列
    @trade_cols_hidden = []
    if $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}")
      @trade_cols_hidden[MagicOrders.trade_mode] = $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}").split(',')
    else
      @trade_cols_hidden[MagicOrders.trade_mode] = []

    # 订单模式可选项列表
    #@trade_modes = {} #MOVED TO TradeSetting.trade_modes

    # 不同模式下可见订单列
    #@trade_cols_visible_modes = {} #MOVED TO TradeSetting.trade_cols_visible_modes

    @original_path = 'trades'
    @cache_trade_number = 0
    @idCarrier = []
    @hasPrint = false
    @enable_trade_deliver_bill_spliting = false
    @enable_trade_deliver_bill_spliting_sellers = []

    new MagicOrders.Routers.Trades()
    new MagicOrders.Routers.TradeSettings()
    new MagicOrders.Routers.DeliverBills()
    new MagicOrders.Routers.LogisticBills()

    Backbone.history.start(pushState: false)
