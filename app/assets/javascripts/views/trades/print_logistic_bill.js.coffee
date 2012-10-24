class MagicOrders.Views.TradesPrintLogisticBill extends Backbone.View

  template: JST['trades/print_logistic_bill']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this
