class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    'trades': 'index'
    'trades/:id': 'show'

  initialize: ->
    @collection = new MagicOrders.Collections.Trades()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  index: ->
    @show_top_nav()
    @collection.fetch()
    view = new MagicOrders.Views.TradesIndex(collection: @collection)
    $('#content').html(view.render().el)