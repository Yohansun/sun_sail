class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'index'
    'trades': 'index'
    'trades/:id': 'show'

  initialize: ->
    $('#content').html('')

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  index: ->
    @show_top_nav()
    @collection = new MagicOrders.Collections.Trades()
    @collection.fetch success: (collection, response) =>
      view = new MagicOrders.Views.TradesIndex(collection: collection)
      $('#content').html(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

  show: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesShow(model: model)
      $('#trade_detail').html(view.render().el)

      $('#trade_detail').on 'hide', (event) ->
        Backbone.history.navigate('trades', true);
      $('#trade_detail').modal('show')