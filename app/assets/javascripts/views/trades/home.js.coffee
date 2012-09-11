class MagicOrders.Views.TradesHome extends Backbone.View

  template: JST['trades/home']

  render: ->
    $(@el).html(@template())
    this