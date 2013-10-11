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
      if data.status_changed == true
        alert("执行操作期间订单状态变化，无法执行锁定")
        $.unblockUI()
        $('#trade_lock_trade').modal('hide')
      else
        $.unblockUI()
        $("#trade_"+data.id).remove()
        $('#trade_lock_trade').modal('hide')