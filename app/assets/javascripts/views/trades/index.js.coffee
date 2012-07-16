class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-type=detail]': 'show_detail'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  show_detail: (e) ->
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id, true);