class MagicOrders.Views.TradesActivateTrade extends Backbone.View

  template: JST['trades/activate_trade']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    $.get '/trades/activate_trade', {id: @model.id, operation: "激活订单"}, (data) ->
      $.unblockUI()
      $("#trade_"+data.id).remove()
      $('#trade_activate_trade').modal('hide')