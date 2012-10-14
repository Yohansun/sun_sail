class MagicOrders.Views.TradesSplited extends Backbone.View

  template: JST['trades/splited']

  events:
    'click .split': 'split'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  split: ->
    split_result = []
    for trade in @model.get('splited')
      for order in trade.orders
        split_result.push {order_id: order.outer_iid, num: order.num, color_num: order.color_num, seller_id: trade.seller_id}

    $.get '/trades/' + @model.id + '/split_trade', {split_result: split_result}, (data) =>
      $("#trade_" + @model.id).hide()
      for trade_id in data.ids
        trade = new MagicOrders.Models.Trade(id: trade_id)
        trade.fetch success: (model, response) =>
          view = new MagicOrders.Views.TradesRow(model: model)
          $("#trade_" + @model.id).after(view.render().el)

      $('#trade_splited').modal('hide')
