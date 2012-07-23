class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-type=detail]': 'show_detail'
    'click [data-type=seller]': 'show_seller'
    'click [data-trade-type]': 'change_trade_type'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  show_detail: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/detail', true)

  show_seller: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/seller', true)

  show_deliver: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/deliver', true)

  change_trade_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)