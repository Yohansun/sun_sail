class MagicOrders.Views.TradesOperationLog extends Backbone.View

  template: JST['trades/operation_log']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this