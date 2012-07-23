class MagicOrders.Views.TradesDeliver extends Backbone.View

  template: JST['trades/deliver']

  events:
    'click .deliver': 'deliver'

  initialize: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  deliver: ->
    @model.save 'delivered_at', true, success: (model, response) =>
      $('#trade_deliver').modal('hide')
      window.history.back()