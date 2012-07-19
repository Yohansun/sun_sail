class MagicOrders.Views.TradesSeller extends Backbone.View

  template: JST['trades/seller']

  initliaze: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this