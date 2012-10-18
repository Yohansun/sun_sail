class MagicOrders.Views.TradesColorInfo extends Backbone.View

  template: JST['trades/color_info']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this