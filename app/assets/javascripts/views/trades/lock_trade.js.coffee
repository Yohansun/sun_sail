class MagicOrders.Views.TradesLockTrade extends Backbone.View

  template: JST['trades/lock_trade']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    $.get '/trades/lock_trade', {id: @model.id, operation: "锁定订单"}, (data) ->
      $.unblockUI()
      $("#trade_"+data.id).hide()
      $('#trade_lock_trade').modal('hide')