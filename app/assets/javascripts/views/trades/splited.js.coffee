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
    $.get '/api/trades/' + @model.id + '/split_trade', {}, (data) =>
      $("#trade_" + @model.id).hide()
      for trade_id in data.ids
        trade = new MagicOrders.Models.Trade(id: trade_id)
        trade.fetch success: (model, response) =>
          view = new MagicOrders.Views.TradesRow(model: model)
          $("#trade_" + @model.id).after(view.render().el)

      $('#trade_splited').modal('hide')
