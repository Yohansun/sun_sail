class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'index'
    'trades': 'index'
    'trades/:trade_type': 'index'
    'trades/:id/detail': 'show'
    'trades/:id/seller': 'seller'
    'trades/:id/deliver': 'deliver'
    'trades/:id/cs_memo': 'cs_memo'

  initialize: ->
    $('#content').html('')

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  index: (trade_type = null) ->
    @show_top_nav()
    @collection = new MagicOrders.Collections.Trades()
    @collection.fetch data: {trade_type: trade_type}, success: (collection, response) =>
      view = new MagicOrders.Views.TradesIndex(collection: collection, trade_type: trade_type)
      $('#content').html(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

  show: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesShow(model: model)
      $('#trade_detail').html(view.render().el)

      $('#trade_detail').on 'hide', (event) ->
        window.history.back()
      $('#trade_detail').modal('show')

  seller: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesSeller(model: model)
      $('#trade_seller').html(view.render().el)

      $('#trade_seller').on 'hide', (event) ->
        window.history.back()
      $('#trade_seller').modal('show')

  deliver: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesDeliver(model: model)
      $('#trade_deliver').html(view.render().el)

      $('#trade_deliver').on 'hide', (event) ->
        window.history.back()

      $('#trade_deliver').modal('show')

  cs_memo: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesCsMemo(model: model)

      $('#trade_cs_memo').html(view.render().el)
      $('#cs_memo_text').val(model.get('cs_memo'))
      $('#trade_cs_memo').on 'hide', (event) ->
        window.history.back()

      $('#trade_cs_memo').modal('show')
