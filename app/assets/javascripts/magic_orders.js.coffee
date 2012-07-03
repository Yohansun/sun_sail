window.MagicOrders =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    new MagicOrders.Routers.Areas()
    Backbone.history.start(pushState: true)
