window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    new MagicOrders.Routers.Areas()
    new MagicOrders.Routers.Trades()
    Backbone.history.start(pushState: true)
    # Backbone.history.navigate('trades');