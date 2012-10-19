class MagicOrders.Views.TradesSelectPrintTime extends Backbone.View

  template: JST['trades/select_print_time']

  render: ->
    $(@el).html(@template())
    this