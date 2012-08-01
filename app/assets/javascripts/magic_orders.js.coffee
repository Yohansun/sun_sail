window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    @trade_pops = {
      'cs': ['detail', 'seller', 'cs_memo', 'color', 'invoice'],
      'seller': ['detail', 'deliver', 'seller_confirm_deliver', 'seller_confirm_invoice'],
      'admin': ['*']
    }
    new MagicOrders.Routers.Areas()
    new MagicOrders.Routers.Trades()
    new MagicOrders.Routers.Sellers()
    Backbone.history.start(pushState: true)