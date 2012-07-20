class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-type=detail]': 'show_detail'
    'click [data-type=seller]': 'show_seller'
    'click [data-type=deliver]': 'show_deliver'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  show_detail: (e) ->
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id, true)

  show_seller: (e) ->
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/seller', true)

  show_deliver: (e) ->
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/deliver', true)