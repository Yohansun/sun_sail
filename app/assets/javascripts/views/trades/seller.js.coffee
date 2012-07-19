class MagicOrders.Views.TradesSeller extends Backbone.View

  template: JST['trades/seller']

  events:
    'click .set_seller': 'set_seller'

  initliaze: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  set_seller: ->
    if $("#trade_seller_id").val() > 0
      @model.save 'seller_id', $("#trade_seller_id").val(), success: (model, response) =>
        $('#trade_seller').modal('hide')
        Backbone.history.navigate('trades', true);