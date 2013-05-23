class MagicOrders.Views.TradesBatchCheckGoods extends Backbone.View

  template: JST['trades/batch_check_goods']

  events:
    'click .confirm_button': 'save'

  initialize: ->
    @collection.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  save: ->
    blocktheui()
    trade_ids = @collection.map((trade)->
      return trade.id
    )
    $.get '/trades/batch_check_goods', {ids: trade_ids}, (result) ->
      $.unblockUI()
      $('#trade_batch_check_goods').modal('hide')

