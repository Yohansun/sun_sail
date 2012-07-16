class MagicOrders.Views.TradesShow extends Backbone.View

  template: JST['trades/show']

  initliaze: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this