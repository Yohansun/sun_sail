class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this